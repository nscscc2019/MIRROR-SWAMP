本目录提供大赛功能测试包。


更新日志
--v0.01：20190514
         1.第一次发布。
         
目录结构：
   +--cpu132_gettrace/   : gs132生成golden_trace的环境，架构为SoC_SRAM_Lite，默认已生产golden_trace.txt
   |        
   |--soc_axi_func/      : AXI接口的CPU运行环境，架构为SoC_AXI_Lite
   |        
   |--soc_sram_func/     : SRAM接口的CPU运行环境，架构为SoC_SRAM_Lite
   |        
   |--soft/              : 89个功能点测试程序和记忆游戏测试程序，默认已包含编译好的结果
   |        
   |--功能测试说明.pdf   : 功能测试说明文档
   |        
   |--Readme_First.txt   : 本文档
