# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param synth.incrementalSynthesisCache C:/Users/Martin/AppData/Roaming/Xilinx/Vivado/.Xil/Vivado-9644-Martin-PC/incrSyn
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7z020clg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.cache/wt} [current_project]
set_property parent.project_path {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_output_repo {e:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/common_types_and_functions.vhd}
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/gauss_jordan_pkg.vhd}
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/Transpose.vhd}
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/Correlation.vhd}
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/inverse_matrix.vhd}
  {E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/fsm_inverse_matrix.vhd}
}
read_vhdl -vhdl2008 -library xil_defaultlib {{E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/new/forward_elim_gauss.vhd}}
read_ip -quiet {{E:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci}}
set_property used_in_implementation false [get_files -all {{e:/One Drive/OneDrive for Business/NTNU/Master/Anomaly-detection/FPGA_implementation/Anomaly_detection/Anomaly_detection.srcs/sources_1/ip/mult_gen_0/mult_gen_0_ooc.xdc}}]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}

synth_design -top forward_elim_gauss -part xc7z020clg484-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef forward_elim_gauss.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file forward_elim_gauss_utilization_synth.rpt -pb forward_elim_gauss_utilization_synth.pb"
