!\\Nov 24 2021 - chg default browser type to Chrome
!\\Feb 17 2021 - Added default mapkeys
!\\Aug 17 2020
!\\feb 18 2022 - fixed syntax error dm_hide_virtual_default Yes      to      dm_hide_virtual_default_ws Yes
!\\feb 18 2022 - removed relat_marks_obj_modified no as it is not supported in creo 6


dm_emulate_ilink_sys_parameters yes
dm_hide_virtual_default_ws Yes
dm_upload_objects explicit
dm_checkout_on_the_fly continue
trail_dir C:\creo6\created\trail

!\\dm_network_threads 2
!\\dm_network_request_size 100000

!\\relat_marks_obj_modified no
bump_revnum_on_retr_regen no

pro_font_dir c:\windows\fonts
sim_solver_memory_allocation 2000

save_instance_accelerator none

system_colors_file C:\creo6\config\syscol.scl

show_axes_for_extr_arcs yes
multiple_skeletons_allowed yes
enable_absolute_accuracy yes

!\\Control initial view
spin_center_display no
spin_with_part_entities yes
spin_with_silhouettes yes
display_full_object_path yes
display_axis_tags yes
display_axes no
display_annotations no
display_coord_sys no
display_plane_tags yes
display_planes no
display_point_tags yes
display_points no

!\\Drawing control item
allow_move_view_with_move yes

enable_creo_simulation_live no

!\\windows_browser_type ie_browser
windows_browser_type chromium_browser
web_browser_homepage about:blank
!\\web_browser_homepage http://xxx.xx/Windchill/app/
enable_3dmodelspace_browser_tab no
enable_partcommunity_tab no
enable_punditas_browser_tab no
js_error_policy suppress_continue

intf2d_out_pdf_stroke_text_font all

!\\Default Mapkeys
mapkey mass_g @MAPKEY_NAMEAdds a relation to the part;\
mapkey(continued) @MAPKEY_LABELMASS_G Relation;\
mapkey(continued) ~ Activate `main_dlg_cur` `page_Tools_control_btn` 1;\
mapkey(continued) ~ Command `ProCmdMmRels` ;~ Arm `relation_dlg` `RelText`;\
mapkey(continued) ~ Update `relation_dlg` `RelText` 1 52 78 1 `\nMASS_G=PRO_MP_MASS*1000000`;\
mapkey(continued) ~ Activate `relation_dlg` `TBVerify`;~ Activate `UI Message Dialog` `ok`;\
mapkey(continued) ~ FocusIn `relation_dlg` `ParamsPHLay.ParTable`;\
mapkey(continued) ~ Activate `relation_dlg` `PB_OK`;
















