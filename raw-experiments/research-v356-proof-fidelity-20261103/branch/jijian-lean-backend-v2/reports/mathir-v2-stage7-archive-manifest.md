# MathIR v2 Stage 7 原始证据归档清单

完整逐题原始结果保存在本机 `reports/mathir-v2-stage7-live-cases/`，不纳入 Git。压缩流与解压内容均校验 SHA-256；复核时可用 `gzip -dc <file> | shasum -a 256` 检查原始字节，或 `shasum -a 256 <file>` 检查归档本身。

| 文件 | gzip bytes | gzip SHA-256 | 解压 bytes | 解压 SHA-256 |
|---|---:|---|---:|---|
| `C03-captured.json.gz` | 8,771 | `158b58254386b0742a1688ac5e383c0cb1e6cf2127897e829a068f5cad7d9c9b` | 203,226 | `ef93fc08f80df54c104d83bbbd6b94e455f8702ae2b4120dce11fb4caca72d10` |
| `C03-recovered.json.gz` | 3,671 | `3f7f25ab9f50957d35b759fbe59b14757511e1c237689aae1f8e52a69c40ee23` | 16,741 | `8f2c381dfb5b3629e9013fd79eb2e96639edf00a3e5f74d3d8fa784c24fa8045` |
| `C13.json.gz` | 46,978,014 | `2369afbd6bcaf2a04d0654cc27bbdf6f0a611156600553b628b49199c43b3a13` | 1,792,200,782 | `f95ded2363fa3d15c980ff55415f465765c34d8a903644bae6ad319bccc2a672` |
| `C14.json.gz` | 26,688,255 | `511751250bee50315508cc0a45f49c3a762c066db4ee9597c91f8ebcf7507ff4` | 1,038,115,999 | `4aae161d3e14ac9f892ce6f1c25d33612a45c80c372e221ef3dcb1d9962b8a00` |

C13/C14 each contain a complete JSON research record and certificate/AST evidence; compression is lossless. The smaller C01–C12/C15 case records remain as JSON beside these archives. The ignored generated aggregate `mathir-v2-stage7-final-evidence.json` is reproducible with `python scripts/build_stage7_report.py`; it is not the archive of record for the two multi-gigabyte outputs.
