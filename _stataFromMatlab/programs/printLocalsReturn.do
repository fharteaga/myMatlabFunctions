program printLocalsReturn

	args  id tabla

	return list

	* Weird "hidden" attributes that I don't want to export (see return list, all)
	local weird_scalars PT_has_legend PT_has_cnotes PT_k_ctitles outcomeIsEq1 j2_1 j1_1 deriv1 is_xb1 numeric 
	local weird_macros marg_dims put_tables isloco PT_rseps PT_rnotes PT_raligns PT_rtitles PT_cformats PT_cspans2 PT_ctitles2 PT_cspans1 PT_ctitles1 citype predict
	local weird_matrices PT

	* Export los scalars

	local scalars: r(scalars)
	foreach s in  `scalars' {
		//	di "`s' : `r(`s')' "
		local write 1
		foreach w in `weird_scalars'{
			if ("`s'"=="`w'"){
				local write 0
			}
		}
		if(`write'==1){
			file write `tabla'  "`id',`s',`r(`s')',,,1,0,0" _n
		}
	}

 	* Export los macros
	local macros: r(macros)
	foreach m in  `macros'{
		local write 1
		foreach w in `weird_macros'{
			if ("`m'"=="`w'"){
				local write 0
			}
		}
		if(`write'==1){
			file write `tabla'   "`id',`m',,"_char(34)"`r(`m')'"_char(34)",,0,1,0" _n
		}
	}

  	* Export las matrices
	local matrices: r(matrices)
	foreach m in  `matrices'{

		local write 1
		foreach w in `weird_matrices'{
			if ("`m'"=="`w'"){
				local write 0
			}
		}
		if (`write'==1){
			matrix ma = r(`m')
			local rows= rowsof(ma)
			local cols=colsof(ma)

			file write `tabla'   "`id',`m'_NRows,,,`rows',0,0,1" _n
			file write `tabla'   "`id',`m'_NCols,,,`cols',0,0,1" _n
			forv c=1/`cols'{
				forv r=1/`rows'{
					local val=ma[`r',`c']
					file write `tabla'   "`id',`m'_[`r'][`c'],,,`val',0,0,1" _n
				}
			}
		}
	}

	* Clear results:
	return clear
end
