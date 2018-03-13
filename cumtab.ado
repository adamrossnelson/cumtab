*! cumtab v1.0.0 ARNelson 02mar2018

program cumtab, rclass
    // Version control
    version 15

    preserve
    syntax varlist(min=1 max=3 numeric) [if] [in] [, UCase(string) CENter SColumn row]

    // Syntax guide:
    // 1st var in varlist must be coded a maximum of three levels
    //    cumtab assums the following:
    //        First level represents not advanced
    //        Second level represents advanced
    //        Third level represents furthest advanced
    // 2nd var, optional, may be coded any number of levels supported by table
    // 3rd var, optional, may be coded any number of levels supported by table

    tokenize `varlist'

    // Check validity of 1st variable
    qui levelsof `1', local(result_levs)
    local levcount = 0
    foreach lev of local result_levs {
        local ++levcount
    }
    if `levcount' != 3 {
        di as error "First argument limited to three levels."
        error 197
    }

    // If 1st variable 3 levels prepare temp RESULT var
    clonevar RESULT = `1'
    local new_lev = 1
    foreach lev of local result_levs {
        qui recode RESULT (`lev' = `new_lev')
        local ++ new_lev
    }

    // Check for and store number of variables.
    local nvar : word count `varlist'
 
    // Check for proper specification of ucase option.
    if inlist("`ucase'","","seeds","appls","stus","cjust") == 0 {
        di "`ucase'"
        di as error "Use case option (ucase) incorrecly specified"
        error 197
    }

    // Mark the database for if and in specifications
    marksample touse
    quietly count if `touse'
    if `r(N)' == 0 {
        di as error "ERROR: No observations after if or in qualifier."
        error 2000
    }
    
    if `nvar' == 1 {
        gen DIMENSION = 1
        local thevars "DIMENSION RESULT"
    }
    if `nvar' == 2 {
        gen DIMENSION = 1
        clonevar SUB_GROUP_CATEGORY = `2'
        local thevars "DIMENSION RESULT SUB_GROUP_CATEGORY"
    }
    if `nvar' == 3 {
        clonevar DIMENSION = `3'
        clonevar SUB_GROUP_CATEGORY = `2'
        local thevars "DIMENSION RESULT SUB_GROUP_CATEGORY"
    }

    if "`ucase'" == "" | "`ucase'" == "seeds" {    // Seeds are the default use case.
        label define col_head 0 "Total Seeds" 1 "Not Grmntd" 2 "Grmnated" 3 "Fruited"
    }
    else if "`ucase'" == "appls" {                 // Job applications.
        label define col_head 0 "Total Apps" 1 "Not Offered" 2 "Jobs Offered" 3 "Offers Accepted"
    }
    else if "`ucase'" == "stus" {                  // School, scholarship, other applications.
        label define col_head 0 "Total Apps" 1 "Not Admitted" 2 "Admitted" 3 "Matriculated"
    }
    else if "`ucase'" == "cjust" {                  // Criminal justice, arrests, charges, convictions.
        label define col_head 0 "Total Arrests" 1 "Not Charged" 2 "Charged" 3 "Convicted"
    }
    label values RESULT col_head
    
    qui {
        expand 2 if RESULT == 3, generate(_added1)
        replace RESULT = 2 if _added1
        expand 2 if _added1 == 0, generate(_added2)
        replace RESULT = 0 if _added2
    }
    
    table `thevars' if `touse', `center' `scolumn' `row'
    restore
end
