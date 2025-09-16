const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

function getCompanySizeName(sizeCode) {
    const sizeMap = {
        'large': '대기업', 'medium': '중견기업', 'small_medium': '중소기업', 'small_micro': '소기업/소상공인'
    };
    return sizeMap[sizeCode] || sizeCode;
}

router.get('/:diagnosisId', authMiddleware, async (req, res) => {
    const { diagnosisId } = req.params;
    const { userId } = req.user;

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // --- 1. 진단 정보와 사용자의 추천 단체 ID를 함께 조회 ---
        const diagnosisQuery = `
            SELECT d.*, u.business_location, u.company_name, u.recommending_organization_id
            FROM diagnoses d
            JOIN users u ON d.user_id = u.id
            WHERE d.id = $1 AND d.user_id = $2
        `;
        const diagnosisRes = await client.query(diagnosisQuery, [diagnosisId, userId]);

        if (diagnosisRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '진단 정보를 찾을 수 없거나 권한이 없습니다.' });
        }
        const diagnosis = diagnosisRes.rows[0];
        
        // --- 2. 조회된 정보를 바탕으로 변수 설정 ---
        const industryCode = diagnosis.industry_codes[0];
        const region = diagnosis.business_location;
        const companySizeCode = diagnosis.company_size;

        const locationMap = {
            '서울': '서울특별시', '부산': '부산광역시', '대구': '대구광역시', 
            '인천': '인천광역시', '광주': '광주광역시', '대전': '대전광역시',
            '울산': '울산광역시', '세종': '세종특별자치시', '경기': '경기도',
            '강원': '강원특별자치도', '충북': '충청북도', '충남': '충청남도',
            '전북': '전북특별자치도', '전남': '전라남도', '경북': '경상북도',
            '경남': '경상남도', '제주': '제주특별자치도'
        };
        diagnosis.business_location_text = locationMap[region] || region;

        const sizeTranslationMap = {
            'large': '대기업', 'medium': '중견기업', 'small_medium': '중소기업', 'small_micro': '소기업/소상공인'
        };
        const companySizeKey = sizeTranslationMap[companySizeCode];

        // --- 3. 필요한 모든 데이터를 병렬로 조회 ---
        const [
            answersRes, 
            benchmarkScoresRes, 
            industryIssuesRes, 
            regionalIssuesRes, 
            programsRes,
            questionsRes, 
            strategyRulesRes,
            industryAverageRes,
            companySizeIssuesRes,
            solutionCategoriesRes
        ] = await Promise.all([
            client.query('SELECT * FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosisId]),
            client.query('SELECT * FROM industry_benchmark_scores WHERE industry_code = $1', [industryCode]),
            client.query('SELECT * FROM industry_esg_issues WHERE industry_code = $1', [industryCode]),
            client.query('SELECT * FROM regional_esg_issues WHERE region = $1 ORDER BY esg_category', [region]),
            client.query(`
                SELECT p.*, COALESCE(sc.categories, '[]'::json) as solution_categories
                FROM esg_programs p
                LEFT JOIN (
                    SELECT psc.program_id, json_agg(sc.category_name) as categories
                    FROM program_solution_categories psc
                    JOIN solution_categories sc ON psc.category_id = sc.id
                    GROUP BY psc.program_id
                ) sc ON p.id = sc.program_id
                WHERE p.status = 'published'
            `),
            client.query("SELECT question_code, question_text, esg_category FROM survey_questions WHERE diagnosis_type = 'simple'"),
            client.query('SELECT * FROM strategy_rules'),
            client.query('SELECT * FROM industry_averages WHERE industry_code = $1', [industryCode]),
            client.query('SELECT * FROM company_size_esg_issues WHERE company_size = $1', [companySizeKey]),
            client.query('SELECT * FROM solution_categories')
        ]);
        
        // ★★★ 4. 대기업 대표 프로그램 정보 조회 (새로 추가된 부분) ★★★
        let selectedCompanyPrograms = null;
        let industryCompanyPrograms = [];

        if (diagnosis.selected_major_company_id) {
            const selectedCompanyRes = await client.query(
                `SELECT mc.id, mc.company_name, 
                        (SELECT json_agg(mcp.*) FROM major_company_programs mcp WHERE mcp.company_id = mc.id) as programs
                 FROM major_companies mc
                 WHERE mc.id = $1`,
                [diagnosis.selected_major_company_id]
            );
            if (selectedCompanyRes.rows.length > 0) {
                selectedCompanyPrograms = selectedCompanyRes.rows[0];
                if (!selectedCompanyPrograms.programs) {
                    selectedCompanyPrograms.programs = [];
                }
            }
        }        
        const userAnswers = answersRes.rows;
        const allPrograms = programsRes.rows;
        const allQuestions = questionsRes.rows;
        const allRules = strategyRulesRes.rows;
        const industryAverageData = industryAverageRes.rows[0] || {};
        
        // --- 4. 우선 추천 프로그램 선정 로직 ---
        let priorityProgramList = [];
        const priorityProgramIds = new Set();

        // 4-1. 사용자의 '추천 단체'가 작성한 프로그램
        if (diagnosis.recommending_organization_id) {
            const partnerPrograms = allPrograms.filter(p => p.author_id === diagnosis.recommending_organization_id);
            partnerPrograms.forEach(p => {
                if (!priorityProgramIds.has(p.id)) {
                    priorityProgramList.push(p);
                    priorityProgramIds.add(p.id);
                }
            });
        }
        // 4-2. 관리자가 '우선 추천'으로 지정한 프로그램
        const adminRecommendedPrograms = allPrograms.filter(p => p.is_admin_recommended === true);
        adminRecommendedPrograms.forEach(p => {
            if (!priorityProgramIds.has(p.id)) {
                priorityProgramList.push(p);
                priorityProgramIds.add(p.id);
            }
        });

        // --- 5. 엔진 추천 프로그램 선정 로직 ---
        let engineRecommendedProgramCodes = new Set();
        allRules.forEach(rule => {
            let ruleMet = false;
            const conditions = rule.conditions;
            if (!conditions || !conditions.rules) return;

            const ruleResults = conditions.rules.map(subRule => {
                if (subRule.type === 'category_score') {
                    const userScore = parseFloat(diagnosis[`${subRule.item.toLowerCase()}_score`]);
                    if (isNaN(userScore)) return false;
                    if (subRule.operator === '<') return userScore < subRule.value;
                    if (subRule.operator === '<=') return userScore <= subRule.value;
                    if (subRule.operator === '>') return userScore > subRule.value;
                    if (subRule.operator === '>=') return userScore >= subRule.value;
                    if (subRule.operator === '==') return userScore == subRule.value;
                }
                if (subRule.type === 'question_score') {
                    const userAnswer = userAnswers.find(ans => ans.question_code === subRule.item);
                    if (userAnswer && userAnswer.score !== null) {
                        const userAnswerScore = parseFloat(userAnswer.score);
                        if (isNaN(userAnswerScore)) return false;
                        if (subRule.operator === '==') return userAnswerScore == subRule.value;
                        if (subRule.operator === '>=') return userAnswerScore >= subRule.value;
                        if (subRule.operator === '>') return userAnswerScore > subRule.value;
                        if (subRule.operator === '<=') return userAnswerScore <= subRule.value;
                        if (subRule.operator === '<') return userAnswerScore < subRule.value;
                    }
                }
                return false;
            });

            if (conditions.operator === 'AND') {
                ruleMet = ruleResults.every(res => res === true);
            } else if (conditions.operator === 'OR') {
                ruleMet = ruleResults.some(res => res === true);
            }

            if (ruleMet) {
                engineRecommendedProgramCodes.add(rule.recommended_program_code);
            }
        });
        
        // 엔진 추천 프로그램 목록 필터링 (단, 우선 추천된 프로그램은 제외)
        const engineRecommendedPrograms = allPrograms.filter(p => 
            engineRecommendedProgramCodes.has(p.program_code) && !priorityProgramIds.has(p.id)
        );

        // --- 6. AI 분석 평가 데이터 가공 ---
        const userTotalScore = parseFloat(diagnosis.total_score);
        const scoresByMainQuestion = {};
        benchmarkScoresRes.rows.forEach(item => {
            const match = item.question_code.match(/S-Q(\d+)/);
            if (match) {
                const mainQuestionNum = match[1];
                if (!scoresByMainQuestion[mainQuestionNum]) scoresByMainQuestion[mainQuestionNum] = [];
                scoresByMainQuestion[mainQuestionNum].push(parseFloat(item.average_score || 0));
            }
        });
        const representativeScores = Object.values(scoresByMainQuestion).map(scores => Math.max(...scores));
        let industryAvgTotalScore = 0;
        if (representativeScores.length > 0) {
            const sumOfScores = representativeScores.reduce((sum, score) => sum + score, 0);
            industryAvgTotalScore = sumOfScores / representativeScores.length;
        }
        let percentageDiff = 0;
        if (industryAvgTotalScore > 0) {
            percentageDiff = ((userTotalScore / industryAvgTotalScore) - 1) * 100;
        }
        let status = '비슷';
        if (percentageDiff > 10) { status = '우수'; } 
        else if (percentageDiff < -10) { status = '부족'; }
        
        const allRecommendedPrograms = [...priorityProgramList, ...engineRecommendedPrograms];
        const uniqueRecommendedCategories = [...new Set(
            allRecommendedPrograms.flatMap(p => p.solution_categories || [])
        )];
        
        const aiAnalysisData = {
            userName: diagnosis.company_name,
            percentageDiff, status, userTotalScore, industryAvgTotalScore,
            industryMainIssue: industryIssuesRes.rows[0]?.key_issue || '해당 산업의 주요 이슈 정보 없음',
            regionMainIssue: regionalIssuesRes.rows[0]?.content || '아래 지도의 사안',
            recommendedCategories: uniqueRecommendedCategories
        };

        // --- 7. 최종 응답 전송 ---
        await client.query('COMMIT');
        res.status(200).json({
            success: true,
            strategyData: {
                userDiagnosis: diagnosis,
                benchmarkScores: benchmarkScoresRes.rows,
                userAnswers: userAnswers,
                allQuestions: allQuestions,
                industryIssues: industryIssuesRes.rows,
                regionalIssues: regionalIssuesRes.rows,
                priorityRecommendedPrograms: priorityProgramList, 
                engineRecommendedPrograms: engineRecommendedPrograms,
                industryAverageData: industryAverageData,
                aiAnalysis: aiAnalysisData,
                companySizeIssue: companySizeIssuesRes.rows[0] || null,
                allSolutionCategories: solutionCategoriesRes.rows
            }
        });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("전략 생성 에러:", error);
        res.status(500).json({ success: false, message: '전략을 생성하는 중 서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

module.exports = router;
