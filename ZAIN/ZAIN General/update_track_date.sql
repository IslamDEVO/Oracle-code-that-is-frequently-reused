function dt_ud_mode (p_effective_date     varchar2,
                        p_base_table_name    varchar2,
                        p_base_key_column    varchar2,
                        p_base_key_value     varchar2)
      return varchar2
   as
      lc_dt_ud_mode             varchar2 (100) := null;
      lb_correction             boolean;
      lb_update                 boolean;
      lb_update_override        boolean;
      lb_update_change_insert   boolean;
   begin
      dt_api.find_dt_upd_modes (
         p_effective_date         => trunc (
                                       to_date (p_effective_date,
                                                'YYYY/MM/DD HH24:MI:SS')),
         p_base_table_name        => p_base_table_name,
         p_base_key_column        => p_base_key_column,
         p_base_key_value         => p_base_key_value,
         p_correction             => lb_correction,
         p_update                 => lb_update,
         p_update_override        => lb_update_override,
         p_update_change_insert   => lb_update_change_insert);


      if (lb_update_override = true or lb_update_change_insert = true)
      then
         lc_dt_ud_mode := 'UPDATE_OVERRIDE';
      end if;

      if (lb_correction = true)
      then
         lc_dt_ud_mode := 'CORRECTION';
      end if;

      if (lb_update = true)
      then
         lc_dt_ud_mode := 'UPDATE';
      end if;

      return lc_dt_ud_mode;
   end;

   ------------------
   l_dt_ud_mode :=
         dt_ud_mode (p_effective_date    => p_effective_date,
                     p_base_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                     p_base_key_column   => 'ASSIGNMENT_ID',
                     p_base_key_value    => l_assignment_id);

    -------------------
    [4:26 PM, 7/26/2022] Maged Hits: l_dt_ud_mode :=
         dt_ud_mode (p_effective_date    => p_effective_date,
                     p_base_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                     p_base_key_column   => 'ASSIGNMENT_ID',
                     p_base_key_value    => l_assignment_id);

      begin
         hr_assignment_api.update_emp_asg (
            p_validate                 => false,
            p_effective_date           => trunc (
                                            to_date (p_effective_date,
                                                     'YYYY/MM/DD HH24:MI:SS')),
            p_datetrack_update_mode    => l_dt_ud_mode,
            p_assignment_id            => l_assignment_id,
            p_object_version_number    => l_object_version_number,
            p_ass_attribute6           => l_ticket_entitilment,
            p_concatenated_segments    => l_concatenated_segments,
            p_soft_coding_keyflex_id   => l_soft_coding_keyflex_id,
            p_comment_id               => l_comment_id,
            p_effective_start_date     => l_effective_start_date,
            p_effective_end_date       => l_effective_end_date,
            p_no_managers_warning      => l_no_managers_warning,
            p_other_manager_warning    => l_other_manager_warning);
