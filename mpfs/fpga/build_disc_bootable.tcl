# build_disc_bootable.tcl -- add the HSS eNVM boot client to the (already P&R'd, timing-MET)
# libero_disc project and export the COMPLETE delivery job (FABRIC + SNVM + ENVM). The fabric
# is unchanged (no re-P&R); this only regenerates programming data with HSS in eNVM and exports.
# Adapted from the proven 250T build_corefft_bootable.tcl. See docs/HSS_INTEGRATION.md.
set PROJDIR {C:/Users/lkwangsi/Documents/github/mpfs095t-sar-ifp/mpfs/fpga/libero_disc}
set ENVMCFG {C:/Users/lkwangsi/Documents/github/mpfs095t-sar-ifp/mpfs/fpga/hss/ENVM_disc.cfg}
open_project -file "$PROJDIR/sar_accel.prjx"
project_settings -abort_flow_on_sdc_errors 0
catch { project_settings -abort_flow_on_pdc_errors 0 }
set_root -module {SAR_TOP::work}
puts "@@@ ROOT_SET"

catch { run_tool -name {GENERATEPROGRAMMINGDATA} } e0; puts "@@@ PGD0: $e0"
if {[catch {configure_envm -cfg_file $ENVMCFG} e]} { puts "@@@ ENVM_ERR: $e" } else { puts "@@@ ENVM_OK" }
if {[catch {generate_design_initialization_data} e]} { puts "@@@ DI_ERR: $e" } else { puts "@@@ DI_OK" }
if {[catch {run_tool -name {GENERATEPROGRAMMINGDATA}} e]} { puts "@@@ PGD_ERR: $e" } else { puts "@@@ PGD_OK" }

file mkdir "$PROJDIR/export"
if {[catch {export_prog_job \
    -job_file_name {SAR_TOP_disc_boot} \
    -export_dir "$PROJDIR/export" \
    -bitstream_file_type {TRUSTED_FACILITY} \
    -bitstream_file_components {FABRIC_SNVM ENVM}} e]} { puts "@@@ JOB_ERR: $e" } else { puts "@@@ JOB_OK" }
save_project
puts "@@@ ALLDONE"
