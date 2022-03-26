clear all
cd "C:/Users/boblin/Documents/GitHub/Taiwan_Marriage"
local files : dir "./Data_Raw/PSFD_Adult_Sample/" files "*.dta" 
foreach file in `files' {	
    local name = substr("`file'", 1,  strlen("`file'") - 4)
	local names `names' "`name'"
	use	"./Data_Raw/PSFD_Adult_Sample/`file'", clear
	gen survey_name = "`name'"
	capture tostring x02, replace
	save ./Data_Modified/`name'_modified.dta, replace
}
clear
foreach name in `names' {
    append using "./Data_Modified/`name'_modified.dta", force
}

capture program drop merge_vars
program merge_vars
	tempvar check
	gen `check' = (`1' != `2') & `1' != . & `2' != .
	tab `check' if `check' == 1
	return list
	if r(N) == 0 {
	    replace `1' = `2' if `1' == .
		drop `2'
	}
	else{
	    di "inconsistent"
	}
end

merge_vars d01z01 d01a01
merge_vars d01z01 d01z1
merge_vars d01z01 d01a
tab d01z01

merge_vars a02 a02a01
merge_vars a02 a02z01
rename a02 birth_year
replace birth_year = birth_year + 1911

gen survey_year = substr(survey_name, -4,  strlen(survey_name))
destring survey_year,  replace
gen age = survey_year - birth_year
tab age survey_year
save "./Data_Modified/main_data_merged.dta", replace