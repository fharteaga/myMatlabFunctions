program printLocalsEReturn

	args  id tabla

	ereturn list

	* Export los scalars

	local scalars: e(scalars)
	foreach s in  `scalars' {
		//	di "`s' : `e(`s')' "
		file write `tabla'  "`id',`s',`e(`s')',,,1,0,0" _n
	}

 	* Export los macros
	local macros: e(macros)
	foreach m in  `macros'{
		file write `tabla'   "`id',`m',,"_char(34)"`e(`m')'"_char(34)",,0,1,0" _n
	}

  	* Export las matrices
	local matrices: e(matrices)
	foreach m in  `matrices'{

		matrix ma = e(`m')
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

	* Clear results:
	ereturn clear
end
