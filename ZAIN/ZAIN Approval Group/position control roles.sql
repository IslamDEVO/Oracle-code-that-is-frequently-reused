select p.person_id, p.full_name, r.role_id, r.role_name,
        pei.pei_information4        default_role,
        r.enable_flag             role_enable_flag,
        pei.pei_information5        user_enable_flag,
        1 seq_order
from per_people_extra_info pei
join per_all_people_f p
on (pei.person_id = p.person_id
    and sysdate between p.effective_start_date and p.effective_end_date)
join fnd_user usr
on (p.person_id = usr.employee_id and nvl(usr.end_date, hr_general.end_of_time) >= sysdate)
join pqh_roles r
on (pei.PEI_INFORMATION3 = r.role_id
    and r.ENABLE_FLAG = 'Y'
    and pei.PEI_INFORMATION5 = 'Y'
    and pei.INFORMATION_TYPE = 'PQH_ROLE_USERS')
where r.role_name = 'HR - Outsource Development'
order by seq_order