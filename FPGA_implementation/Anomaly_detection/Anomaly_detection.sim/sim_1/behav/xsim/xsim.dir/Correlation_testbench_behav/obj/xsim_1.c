/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_2655(char*, char *);
extern void execute_2656(char*, char *);
extern void execute_34(char*, char *);
extern void execute_33(char*, char *);
extern void execute_93(char*, char *);
extern void execute_97(char*, char *);
extern void execute_2653(char*, char *);
extern void execute_2654(char*, char *);
extern void execute_2652(char*, char *);
extern void execute_108(char*, char *);
extern void execute_109(char*, char *);
extern void execute_110(char*, char *);
extern void execute_111(char*, char *);
extern void execute_112(char*, char *);
extern void execute_2645(char*, char *);
extern void execute_2640(char*, char *);
extern void execute_133(char*, char *);
extern void execute_154(char*, char *);
extern void execute_170(char*, char *);
extern void execute_186(char*, char *);
extern void execute_202(char*, char *);
extern void execute_218(char*, char *);
extern void execute_234(char*, char *);
extern void execute_250(char*, char *);
extern void execute_266(char*, char *);
extern void execute_282(char*, char *);
extern void execute_298(char*, char *);
extern void execute_314(char*, char *);
extern void execute_330(char*, char *);
extern void execute_346(char*, char *);
extern void execute_362(char*, char *);
extern void execute_378(char*, char *);
extern void execute_394(char*, char *);
extern void execute_411(char*, char *);
extern void execute_422(char*, char *);
extern void execute_439(char*, char *);
extern void execute_455(char*, char *);
extern void execute_471(char*, char *);
extern void execute_487(char*, char *);
extern void execute_503(char*, char *);
extern void execute_519(char*, char *);
extern void execute_535(char*, char *);
extern void execute_551(char*, char *);
extern void execute_567(char*, char *);
extern void execute_583(char*, char *);
extern void execute_599(char*, char *);
extern void execute_615(char*, char *);
extern void execute_631(char*, char *);
extern void execute_647(char*, char *);
extern void execute_663(char*, char *);
extern void execute_679(char*, char *);
extern void execute_696(char*, char *);
extern void execute_707(char*, char *);
extern void execute_724(char*, char *);
extern void execute_740(char*, char *);
extern void execute_756(char*, char *);
extern void execute_772(char*, char *);
extern void execute_788(char*, char *);
extern void execute_804(char*, char *);
extern void execute_820(char*, char *);
extern void execute_836(char*, char *);
extern void execute_852(char*, char *);
extern void execute_868(char*, char *);
extern void execute_884(char*, char *);
extern void execute_900(char*, char *);
extern void execute_916(char*, char *);
extern void execute_932(char*, char *);
extern void execute_948(char*, char *);
extern void execute_964(char*, char *);
extern void execute_981(char*, char *);
extern void execute_992(char*, char *);
extern void execute_1009(char*, char *);
extern void execute_1025(char*, char *);
extern void execute_1041(char*, char *);
extern void execute_1057(char*, char *);
extern void execute_1073(char*, char *);
extern void execute_1089(char*, char *);
extern void execute_1105(char*, char *);
extern void execute_1121(char*, char *);
extern void execute_1137(char*, char *);
extern void execute_1153(char*, char *);
extern void execute_1169(char*, char *);
extern void execute_1185(char*, char *);
extern void execute_1201(char*, char *);
extern void execute_1217(char*, char *);
extern void execute_1233(char*, char *);
extern void execute_1249(char*, char *);
extern void execute_1266(char*, char *);
extern void execute_1277(char*, char *);
extern void execute_1294(char*, char *);
extern void execute_1310(char*, char *);
extern void execute_1326(char*, char *);
extern void execute_1342(char*, char *);
extern void execute_1358(char*, char *);
extern void execute_1374(char*, char *);
extern void execute_1390(char*, char *);
extern void execute_1406(char*, char *);
extern void execute_1422(char*, char *);
extern void execute_1438(char*, char *);
extern void execute_1454(char*, char *);
extern void execute_1470(char*, char *);
extern void execute_1486(char*, char *);
extern void execute_1502(char*, char *);
extern void execute_1518(char*, char *);
extern void execute_1534(char*, char *);
extern void execute_1551(char*, char *);
extern void execute_1562(char*, char *);
extern void execute_1579(char*, char *);
extern void execute_1595(char*, char *);
extern void execute_1611(char*, char *);
extern void execute_1627(char*, char *);
extern void execute_1643(char*, char *);
extern void execute_1659(char*, char *);
extern void execute_1675(char*, char *);
extern void execute_1691(char*, char *);
extern void execute_1707(char*, char *);
extern void execute_1723(char*, char *);
extern void execute_1739(char*, char *);
extern void execute_1755(char*, char *);
extern void execute_1771(char*, char *);
extern void execute_1787(char*, char *);
extern void execute_1803(char*, char *);
extern void execute_1819(char*, char *);
extern void execute_1836(char*, char *);
extern void execute_1847(char*, char *);
extern void execute_1864(char*, char *);
extern void execute_1880(char*, char *);
extern void execute_1896(char*, char *);
extern void execute_1912(char*, char *);
extern void execute_1928(char*, char *);
extern void execute_1944(char*, char *);
extern void execute_1960(char*, char *);
extern void execute_1976(char*, char *);
extern void execute_1992(char*, char *);
extern void execute_2008(char*, char *);
extern void execute_2024(char*, char *);
extern void execute_2040(char*, char *);
extern void execute_2056(char*, char *);
extern void execute_2072(char*, char *);
extern void execute_2088(char*, char *);
extern void execute_2104(char*, char *);
extern void execute_2121(char*, char *);
extern void execute_2129(char*, char *);
extern void execute_2144(char*, char *);
extern void execute_2158(char*, char *);
extern void execute_2172(char*, char *);
extern void execute_2186(char*, char *);
extern void execute_2200(char*, char *);
extern void execute_2214(char*, char *);
extern void execute_2228(char*, char *);
extern void execute_2242(char*, char *);
extern void execute_2256(char*, char *);
extern void execute_2270(char*, char *);
extern void execute_2284(char*, char *);
extern void execute_2298(char*, char *);
extern void execute_2312(char*, char *);
extern void execute_2326(char*, char *);
extern void execute_2340(char*, char *);
extern void execute_2354(char*, char *);
extern void execute_2369(char*, char *);
extern void execute_2433(char*, char *);
extern void execute_2378(char*, char *);
extern void execute_2380(char*, char *);
extern void execute_2382(char*, char *);
extern void execute_2384(char*, char *);
extern void execute_2386(char*, char *);
extern void execute_2388(char*, char *);
extern void execute_2390(char*, char *);
extern void execute_2392(char*, char *);
extern void execute_2395(char*, char *);
extern void execute_2397(char*, char *);
extern void execute_2399(char*, char *);
extern void execute_2401(char*, char *);
extern void execute_2403(char*, char *);
extern void execute_2405(char*, char *);
extern void execute_2407(char*, char *);
extern void execute_2409(char*, char *);
extern void execute_2411(char*, char *);
extern void execute_2413(char*, char *);
extern void execute_2415(char*, char *);
extern void execute_2417(char*, char *);
extern void execute_2419(char*, char *);
extern void execute_2421(char*, char *);
extern void execute_2423(char*, char *);
extern void execute_2425(char*, char *);
extern void execute_2427(char*, char *);
extern void execute_2429(char*, char *);
extern void execute_2431(char*, char *);
extern void execute_2440(char*, char *);
extern void execute_2450(char*, char *);
extern void execute_2456(char*, char *);
extern void execute_2466(char*, char *);
extern void execute_2472(char*, char *);
extern void execute_2482(char*, char *);
extern void execute_2488(char*, char *);
extern void execute_2498(char*, char *);
extern void execute_2506(char*, char *);
extern void execute_2512(char*, char *);
extern void execute_2518(char*, char *);
extern void execute_2524(char*, char *);
extern void execute_2540(char*, char *);
extern void execute_2547(char*, char *);
extern void execute_2556(char*, char *);
extern void execute_2561(char*, char *);
extern void execute_2570(char*, char *);
extern void execute_2578(char*, char *);
extern void execute_2584(char*, char *);
extern void execute_2594(char*, char *);
extern void execute_2601(char*, char *);
extern void execute_2610(char*, char *);
extern void execute_2618(char*, char *);
extern void execute_2624(char*, char *);
extern void execute_2631(char*, char *);
extern void execute_2638(char*, char *);
extern void execute_2644(char*, char *);
extern void execute_140(char*, char *);
extern void execute_142(char*, char *);
extern void execute_144(char*, char *);
extern void execute_122(char*, char *);
extern void execute_123(char*, char *);
extern void execute_117(char*, char *);
extern void execute_120(char*, char *);
extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_1(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[224] = {(funcp)execute_2655, (funcp)execute_2656, (funcp)execute_34, (funcp)execute_33, (funcp)execute_93, (funcp)execute_97, (funcp)execute_2653, (funcp)execute_2654, (funcp)execute_2652, (funcp)execute_108, (funcp)execute_109, (funcp)execute_110, (funcp)execute_111, (funcp)execute_112, (funcp)execute_2645, (funcp)execute_2640, (funcp)execute_133, (funcp)execute_154, (funcp)execute_170, (funcp)execute_186, (funcp)execute_202, (funcp)execute_218, (funcp)execute_234, (funcp)execute_250, (funcp)execute_266, (funcp)execute_282, (funcp)execute_298, (funcp)execute_314, (funcp)execute_330, (funcp)execute_346, (funcp)execute_362, (funcp)execute_378, (funcp)execute_394, (funcp)execute_411, (funcp)execute_422, (funcp)execute_439, (funcp)execute_455, (funcp)execute_471, (funcp)execute_487, (funcp)execute_503, (funcp)execute_519, (funcp)execute_535, (funcp)execute_551, (funcp)execute_567, (funcp)execute_583, (funcp)execute_599, (funcp)execute_615, (funcp)execute_631, (funcp)execute_647, (funcp)execute_663, (funcp)execute_679, (funcp)execute_696, (funcp)execute_707, (funcp)execute_724, (funcp)execute_740, (funcp)execute_756, (funcp)execute_772, (funcp)execute_788, (funcp)execute_804, (funcp)execute_820, (funcp)execute_836, (funcp)execute_852, (funcp)execute_868, (funcp)execute_884, (funcp)execute_900, (funcp)execute_916, (funcp)execute_932, (funcp)execute_948, (funcp)execute_964, (funcp)execute_981, (funcp)execute_992, (funcp)execute_1009, (funcp)execute_1025, (funcp)execute_1041, (funcp)execute_1057, (funcp)execute_1073, (funcp)execute_1089, (funcp)execute_1105, (funcp)execute_1121, (funcp)execute_1137, (funcp)execute_1153, (funcp)execute_1169, (funcp)execute_1185, (funcp)execute_1201, (funcp)execute_1217, (funcp)execute_1233, (funcp)execute_1249, (funcp)execute_1266, (funcp)execute_1277, (funcp)execute_1294, (funcp)execute_1310, (funcp)execute_1326, (funcp)execute_1342, (funcp)execute_1358, (funcp)execute_1374, (funcp)execute_1390, (funcp)execute_1406, (funcp)execute_1422, (funcp)execute_1438, (funcp)execute_1454, (funcp)execute_1470, (funcp)execute_1486, (funcp)execute_1502, (funcp)execute_1518, (funcp)execute_1534, (funcp)execute_1551, (funcp)execute_1562, (funcp)execute_1579, (funcp)execute_1595, (funcp)execute_1611, (funcp)execute_1627, (funcp)execute_1643, (funcp)execute_1659, (funcp)execute_1675, (funcp)execute_1691, (funcp)execute_1707, (funcp)execute_1723, (funcp)execute_1739, (funcp)execute_1755, (funcp)execute_1771, (funcp)execute_1787, (funcp)execute_1803, (funcp)execute_1819, (funcp)execute_1836, (funcp)execute_1847, (funcp)execute_1864, (funcp)execute_1880, (funcp)execute_1896, (funcp)execute_1912, (funcp)execute_1928, (funcp)execute_1944, (funcp)execute_1960, (funcp)execute_1976, (funcp)execute_1992, (funcp)execute_2008, (funcp)execute_2024, (funcp)execute_2040, (funcp)execute_2056, (funcp)execute_2072, (funcp)execute_2088, (funcp)execute_2104, (funcp)execute_2121, (funcp)execute_2129, (funcp)execute_2144, (funcp)execute_2158, (funcp)execute_2172, (funcp)execute_2186, (funcp)execute_2200, (funcp)execute_2214, (funcp)execute_2228, (funcp)execute_2242, (funcp)execute_2256, (funcp)execute_2270, (funcp)execute_2284, (funcp)execute_2298, (funcp)execute_2312, (funcp)execute_2326, (funcp)execute_2340, (funcp)execute_2354, (funcp)execute_2369, (funcp)execute_2433, (funcp)execute_2378, (funcp)execute_2380, (funcp)execute_2382, (funcp)execute_2384, (funcp)execute_2386, (funcp)execute_2388, (funcp)execute_2390, (funcp)execute_2392, (funcp)execute_2395, (funcp)execute_2397, (funcp)execute_2399, (funcp)execute_2401, (funcp)execute_2403, (funcp)execute_2405, (funcp)execute_2407, (funcp)execute_2409, (funcp)execute_2411, (funcp)execute_2413, (funcp)execute_2415, (funcp)execute_2417, (funcp)execute_2419, (funcp)execute_2421, (funcp)execute_2423, (funcp)execute_2425, (funcp)execute_2427, (funcp)execute_2429, (funcp)execute_2431, (funcp)execute_2440, (funcp)execute_2450, (funcp)execute_2456, (funcp)execute_2466, (funcp)execute_2472, (funcp)execute_2482, (funcp)execute_2488, (funcp)execute_2498, (funcp)execute_2506, (funcp)execute_2512, (funcp)execute_2518, (funcp)execute_2524, (funcp)execute_2540, (funcp)execute_2547, (funcp)execute_2556, (funcp)execute_2561, (funcp)execute_2570, (funcp)execute_2578, (funcp)execute_2584, (funcp)execute_2594, (funcp)execute_2601, (funcp)execute_2610, (funcp)execute_2618, (funcp)execute_2624, (funcp)execute_2631, (funcp)execute_2638, (funcp)execute_2644, (funcp)execute_140, (funcp)execute_142, (funcp)execute_144, (funcp)execute_122, (funcp)execute_123, (funcp)execute_117, (funcp)execute_120, (funcp)vhdl_transfunc_eventcallback, (funcp)transaction_1};
const int NumRelocateId= 224;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/Correlation_testbench_behav/xsim.reloc",  (void **)funcTab, 224);
	iki_vhdl_file_variable_register(dp + 95752);
	iki_vhdl_file_variable_register(dp + 95808);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/Correlation_testbench_behav/xsim.reloc");
}

void simulate(char *dp)
{
	iki_schedule_processes_at_time_zero(dp, "xsim.dir/Correlation_testbench_behav/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/Correlation_testbench_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/Correlation_testbench_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/Correlation_testbench_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
