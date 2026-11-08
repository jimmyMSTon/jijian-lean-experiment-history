# 三道高难证明首轮真实签名版测试

受测正式安装包：`90a6e5b`
本次只向真实打包后端提交原始数学文字，不曾输入自编 MathIR/Lean/fixture。

| 题目 | DeepSeek真实请求 | 输入Token | 输出Token | 耗时 | 结果 |
|---|---:|---:|---:|---:|---|
| hard_analysis_ivt_sup | 1 | 11495 | 31422 | 130.96s | PARSE_ERROR |
| hard_linear_algebra_spectral | 1 | 11788 | 65106 | 246.27s | PARSE_ERROR |
| hard_number_theory_4k3 | 1 | 11021 | 27983 | 125.58s | PARSE_ERROR |

汇总：{"cases": 3, "realDeepSeekRequests": 3, "inputTokens": 34304, "outputTokens": 124511, "elapsedSeconds": 502.81, "completeLeanKernelSuccesses": 0, "independentOriginalProofSuccesses": 0}

全部三题均在 MathIR JSON 解析阶段失败，因此没有进入 Lean Kernel，没有原稿忠实性证书；不可将这些任务计为数学命题证假、证明正确或未通过 Kernel。

三个模型原始不合法输出均保存在隔离 DB 的 unvalidated_ai_output 中，原内容没有被冒充为通过验证的 MathIR，另有独立真实 AI request ID、source hash、ZIP 审计。


## hard_analysis_ivt_sup

原始题目和证明：设 f:[0,1]→ℝ 连续，且 f(0)<0<f(1)。证明存在 c∈(0,1)，使 f(c)=0。原证明：令 S={x∈[0,1]∣f(x)<0}。因为 f(0)<0，所以 S 非空；又 S⊆[0,1]，故 S 有上确界 c=sup S。由 f 在 0 处连续且 f(0)<0，可知存在 η>0，使得 x∈[0,η] 时 f(x)<0，故 c>0。由 f(1)>0 及连续性可知在 1 的某个左邻域内 f(x)>0，故 c<1。若 f(c)<0，则连续性给出 c 右侧的某点 x∈[0,1] 满足 f(x)<0，与 c 为 S 的上界矛盾。若 f(c)>0，则连续性给出 c 左侧一个邻域内 f(x)>0；但根据上确界定义，存在 x∈S 落在该邻域，与 f(x)<0 矛盾。因此 f(c)=0，且 c∈(0,1)。
请求ID：["9cd90edc-b710-4efc-bc46-d89ecd22e59f"]
响应ID：f452da59-9ee3-4ffe-ad04-e0b189435d7b
错误：PARSE_ERROR / Expecting ',' delimiter @ 11927
模型原始无效输出 ID：27365dac-5b20-4b49-ac65-eb97bd467101
原始无效输出 SHA256：`ccb822c460632268fbf062313e5528d9ed098c78be10cc44d726587a4e40d6e7`
隔离审计 ZIP SHA256：`790df4f9f2a792a305718d5b345974df71aeb88ce628e42fa8d2bdd888d2f820`

## hard_linear_algebra_spectral

原始题目和证明：设 n≥1，A 为 n×n 实对称矩阵，即 Aᵀ=A。证明存在实正交矩阵 Q 与实对角矩阵 D，使 QᵀAQ=D。原证明：对 n 作归纳。n=1 显然。设 n>1。在单位球面 S={x∈ℝⁿ∣∥x∥=1} 上，连续函数 R(x)=xᵀAx 取得最大值 λ，设最大值点为单位向量 v。对任意与 v 正交的 w，考虑 g(t)=R((v+tw)/∥v+tw∥)，在 t=0 取得极大值，故 g′(0)=2wᵀAv=0。因此 Av 与 v 的正交补正交，存在实数 μ 使 Av=μv，且 μ=vᵀAv=λ。由于 A 对称，若 w⊥v，则 ⟨Aw,v⟩=⟨w,Av⟩=λ⟨w,v⟩=0，所以 v⊥ 在 A 下不变。将 A 限制在维数 n−1 的空间 v⊥ 上仍为实对称算子。依归纳假设，v⊥ 有一组由 A 的特征向量组成的标准正交基；与 v 合并得到 ℝⁿ 的标准正交特征向量基。以这些向量为列构成 Q，则 QᵀQ=I，且 QᵀAQ 为实对角矩阵。证毕。
请求ID：["61f24947-c722-4b40-98a2-54c01b5421b7"]
响应ID：74d37d70-9afa-49ba-a1a9-de0629b1154b
错误：PARSE_ERROR / Expecting ',' delimiter @ 33891
模型原始无效输出 ID：dd505ac4-e105-41b6-85f8-b75798da7b5f
原始无效输出 SHA256：`bb7e5d21063f732427535546f56b1c87f115ed90e27f876bc7850af6e07f93e5`
隔离审计 ZIP SHA256：`59b7c21b1d1e4a4f174b431e89f615d289661e6f0a360c534b30f38c5ee1f002`

## hard_number_theory_4k3

原始题目和证明：证明存在无穷多个满足 p≡3 (mod 4) 的素数。原证明：反设所有这样的素数只有 p₁,…,pᵣ。令 P=p₁p₂⋯pᵣ，N=4P−1。N>1 且 N≡3 (mod 4)，所以 N 的素因子中至少一个 q≡3 (mod 4)，否则全部素因子都≡1 (mod 4)，其乘积不可能≡3 (mod 4)。另一方面，对每个 i，有 N=4P−1≡−1 (mod pᵢ)，故 pᵢ 不整除 N。于是 q 不属于 p₁,…,pᵣ，与假设矛盾。因此满足 p≡3 (mod 4) 的素数有无穷多个。
请求ID：["e1262cd6-ef28-4519-8b47-03ba243edb08"]
响应ID：330e1ac9-fbd0-40c5-86e1-b746fa705a3a
错误：PARSE_ERROR / Expecting ',' delimiter @ 8557
模型原始无效输出 ID：5f316167-d866-466f-b14c-82597810be1e
原始无效输出 SHA256：`2d442c9c215228a8883d770c584b0b0deb5c5527658a913a560513f0e55f3e7f`
隔离审计 ZIP SHA256：`415d9cb82b7fb214c3070bd328df3685d90e476bc4e8b2929c24a5eadf369521`
