//1v1 locations/panels SHARED with 3v3 mode

global function ReturnAllSoloLocations
global function ReturnAllPanelLocations
global LocPair &waitingRoomPanelLocation

array<LocPair> function ReturnAllSoloLocations( string mapName )
{
	return FetchReturnAllSoloLocations( mapName )
}

array<LocPair> function ReturnAllPanelLocations()
{
	return FetchReturnAllPanelLocations()
}

array<LocPair> function FetchReturnAllSoloLocations( string mapName )
{
	array<LocPair> allSoloLocations
	
	// LocPair waitingRoomLocation
	if (mapName == "mp_rr_arena_composite")
	{			
		// waitingRoomLocation = NewLocPair( <-7.62,200,184.57>, <0,90,0>)
		waitingRoomPanelLocation = NewLocPair( <-3.0,645,125>, <0,0,0>)//休息区观战面板

		allSoloLocations= [
		NewLocPair( <344.814117, 1279.00415, 188.561081>, <0, 178.998779, 0>), //1
		NewLocPair( <-301.836731, 1278.16309, 188.60759>, <0, -2.78833318, 0>),

		NewLocPair( <-2934.02246, 3094.91431, 192.048279>, <0, 45.9642601, 0>), //2
		NewLocPair( <-2282.98853, 3810.25732, 192.046173>, <0, -120.085022, 0>),

		NewLocPair( <-1037.84583, 2280.85938, -130.952026>, <0, -6.83472872, 0>), //3
		NewLocPair( <-143.20752, 2239.93433, -114.43261>, <0, -178.196396, 0>),

		NewLocPair( <2983.75, 3072.01416, 192.054321>, <0, 138.60434, 0>), //4
		NewLocPair( <2251.52686, 3821.51807, 192.045395>, <0, -59.6830139, 0>),

		NewLocPair( <-694.934387, 4686.71777, 128.03125>, <0, -159.394516, 0>), //5
		NewLocPair( <-1257.71802, 4618.77295, 128.017029>, <0, 7.97793579, 0>),

		NewLocPair( <-851.90686, 5469.09717, -32.0257645>, <0, -3.02725101, 0>), //6
		NewLocPair( <-209.819092, 5462.67139, -30.802206>, <0, -178.949997, 0>),

		NewLocPair( <621.688782, 3920.86963, -31.9940014>, <0, -84.1400604, 0>), //7
		NewLocPair( <709.123413, 3262.09692, -31.96875>, <0, 94.3908463, 0>),

		NewLocPair( <2933.51343, 1449.6571, 140.03125>, <0, -100.364799, 0>), //8
		NewLocPair( <2455.15234, 1004.09894, 128.03125>, <0, 7.74315786, 0>),

		NewLocPair( <-1441.08, 1675.66, 280.08>, <0, -110, 0>),//9
		NewLocPair( <-1787.21, 1008.08, 254.03>, <0, 50, 0>),//9

		NewLocPair( <1649.15588, 1135.37439, 192.03125>, <0, 137.991577, 0>), //10
		NewLocPair( <1122.84058, 1418.50452, 190.821075>, <0, -27.6340904, 0>),

		NewLocPair( <-2862.42407, 1511.31921, 140.03125>, <0, -100.470222, 0>), //11
		NewLocPair( <-2633.31348, 833.701477, 128.03125>, <0, 130.051575, 0>),

		NewLocPair( <-836.684998, 2751.19849, 192.03125>, <0, -150.722626, 0>),//12
		NewLocPair( <-1405.85583, 2548.43164, 192.03125>, <0, 12.0755987, 0>),
		
		]

			
		//drop off patch mkos
		array<LocPair> dropoff_patch
		
		dropoff_patch = [
			
			//removed skyroom
			//NewLocPair( <-1378.05, 559.458, 1026.54 >, < 359.695, 307.314, 0 >),//13
			//NewLocPair( <-1469.03, -117.677, 1026.54 >, < 1.34318, 60.0746, 0 >),
			
			NewLocPair( < -2824.9, 2868.1, -111.969 >, < 0.354577, 31.8209, 0 >), //13
			NewLocPair( < -2541.81, 3919.45, -111.969 >, < 358.65, 315.899, 0 >),

			
			NewLocPair( < -2958.52, 183.899, 190.063 >, < 0.905181, 353.701, 0 >),//14
			NewLocPair( < -1693.05, -663.034, 190.063 >, < 0.514909, 140.627, 0 >),
			
			
			NewLocPair( <2544.54, 3934.15, -111.969 >, < 3.3168, 218.85, 0>), //15
			NewLocPair( <3196.49, 3010.24, -111.969 >, < 1.33276, 134.094, 0>),
			
			NewLocPair( < 2551.65, 515.938, 193.337 >, < 0.894581, 215.161, 0>), //16
			NewLocPair( <1637.37, -808.877, 193.67 >, < 0.0671947, 36.8544, 0>)
		
		]
		
		if ( GetCurrentPlaylistVarBool( "patch_for_dropoff", false ) )
		{
			allSoloLocations.extend(dropoff_patch);
		}
		
		return allSoloLocations
	}
	else if (mapName == "mp_rr_aqueduct")
	{
		// waitingRoomLocation = NewLocPair( <719.94,-5805.13,494.03>, <0,90,0>)
		waitingRoomPanelLocation = NewLocPair( <718.29,-5496.74,430>, <0,0,0>) //休息区观战面板

		allSoloLocations= [

			NewLocPair( <-6775.57568, -204.993729, 106.120445>, <0, -32.8351936, 0>),//1
			NewLocPair( <-6230.72607, -527.870239, 107.595337>, <0, 144.085541, 0>),

			NewLocPair( <3263.02002, -3556.06055, 273.576324>, <0, 8.61375999, 0>),//2
			NewLocPair( <3784.31885, -3452.91772, 272.03125>, <0, -171.17247, 0>),

			NewLocPair( <8502.62109, -615.898987, 315.014832>, <0, -60.9690781, 0>),//3
			NewLocPair( <9021.84863, -1498.87195, 310.646271>, <0, 117.371147, 0>),

			NewLocPair( <167.032883, -6722.06787, 336.03125>, <0, -1.60793841, 0>),//4
			NewLocPair( <1296.91602, -6719.25293, 336.03125>, <0, 178.672043, 0>),

			// NewLocPair( <3654.57104, -4299.94629, 251.554062>, <0, -131.212936, 0>), //remove
			// NewLocPair( <3087.35205, -4413.77637, 256.14917>, <0, -22.8175545, 0>),

			NewLocPair( <-761.57,-4554.79,311.46>, <0, -144.43, 0>),//5
			NewLocPair( <-1436.52,-5086.34,299.21>, <0, 40.96, 0>),

			NewLocPair( <2809.94946, -4459.84961, 361.746124>, <0, -88.6163712, 0>),//6
			NewLocPair( <2738.16772, -5504.04443, 388.564209>, <0, 82.8682785, 0>),

			NewLocPair( <-444.894531, -2472.0481, -313.453186>, <0, -6.28803873, 0>),//7
			NewLocPair( <34.082859, -2517.09546, -311.32724>, <0, 170.668167, 0>),

			NewLocPair( <2050.9939, -3850.13452, 432.03125>, <0, -174.60405, 0>),//8
			NewLocPair( <1504.50134, -3880.59595, 432.03125>, <0, 0.203577876, 0>),

			NewLocPair( <234.719513, -4128.62842, 273.224884>, <0, -94.9567108, 0>),//9
			NewLocPair( <214.551025, -4557.26904, 272.03125>, <0, 87.0343704, 0>),

			NewLocPair( <-5046.05176, -2948.47144, 314.250671>, <0, 63.9120026, 0>),//10
			NewLocPair( <-4553.3623, -2102.83643, 313.807098>, <0, -119.961533, 0>),

			NewLocPair( <-2457.16333, -5476.83203, 400.03125>, <0, -12.8816891, 0>),//11
			NewLocPair( <-1929.41846, -5594.64307, 400.03125>, <0, 165.039886, 0>),

			NewLocPair( <-81.694252, -3906.92749, 432.03125>, <0, 171.290192, 0>),//12
			NewLocPair( <-640.369202, -3834.13794, 432.03125>, <0, -13.2758875, 0>),

			NewLocPair( <-3015.57031, -3553.14819, 272.03125>, <0, -140.035995, 0>),//13
			NewLocPair( <-3493.69263, -4762.4126, 272.032166>, <0, 84.9091492, 0>),
		]
			
		return allSoloLocations
	}
	else if (mapName == "mp_rr_canyonlands_64k_x_64k")
	{
		// waitingRoomLocation = NewLocPair( <-795.58,20362.78,4570.03>, <0,90,0>)   //休息区出生点
		waitingRoomPanelLocation = NewLocPair( <-607.59,20640.05,4570.03>, <0,-45,0>) //休息区观战面板

		allSoloLocations= [

			NewLocPair( <-4896.12, 9610.98, 3528.03>, <0, -90, 0>),//1
			NewLocPair( <-4882.72607, 8705.870239, 3528.595337>, <0, 90.085541, 0>),

			NewLocPair( <8464,8373,5304>, <0, 90, 0>),//2
			NewLocPair( <8349,9969,5304>, <0, -90, 0>),

			NewLocPair( <8760.62109, 27974.898987, 4824.014832>, <0, -177, 0>),//3
			NewLocPair( <6854.84863, 27977.87195, 4824.646271>, <0, 0, 0>),

			NewLocPair( <21030, 7791.06787, 4150.03125>, <0, -173.60793841, 0>),//4
			NewLocPair( <20122.91602, 7161.25293, 4170.03125>, <0, 24.672043, 0>),

			NewLocPair( <-28277.57104, -4377.94629, 2536.554062>, <0, 18.212936, 0>),//5
			NewLocPair( <-27472.52,-3851.34,2536.21>, <0, -146, 0>),

			NewLocPair( <23742.94946, -8292.84961, 4342.746124>, <0, -88.6163712, 0>),//6
			NewLocPair( <24182.16772, -9669.04443, 4535.564209>, <0,94.8682785, 0>),

			NewLocPair( <4168.894531, -9882.0481, 3384.453186>, <0, -155.28803873, 0>),//7
			NewLocPair( <2824.082859, -10359.09546, 3323.32724>, <0, 23.668167, 0>),

			NewLocPair( <3590.9939, -10722.13452, 2816.03125>, <0, 178.60405, 0>),//8
			NewLocPair( <2692.50134, -10735.59595, 2816.03125>, <0, 0, 0>),

			NewLocPair( <-23428.719513, -472.62842, 3752.224884>, <0, 93.9567108, 0>),//9
			NewLocPair( <-23432.551025, 499.26904, 3752.03125>, <0, -89.0343704, 0>),

			NewLocPair( <10801.05176, 1195.47144, 4738.250671>, <0, -15.9120026, 0>),//10
			NewLocPair( <13043.3623, 1027.83643, 4790.807098>, <0, -178.961533, 0>),

			NewLocPair( <13030.16333, 16995.83203, 4763.03125>, <0, 90.8816891, 0>),//11
			NewLocPair( <12933.41846, 18315.64307, 4760.03125>, <0, -92.039886, 0>),

			NewLocPair( <13282.694252, 10734.92749, 4760.03125>, <0, -141.290192, 0>),//12
			NewLocPair( <11905.369202, 9689.13794, 4752.03125>, <0, 37.2758875, 0>),

			NewLocPair( <4519.57031, -7908.14819, 3147.03125>, <0, 161.035995, 0>),//13
			NewLocPair( <2328.69263, -7650.4126, 3352.032166>, <0, 7.9091492, 0>),

			NewLocPair( <4016.10693, -3406.61035, 2652.67822>, <0,-22,0> ),//14
			NewLocPair( <4875,-3494,2738>, <0,144,0> ),

			NewLocPair( <26629,-17691,5424>, <0,-179,0> ),//15
			NewLocPair( <24074,-17726,5424>, <0,-1,0> ),

			NewLocPair( <-7434,5519,2470>, <0,-178,0> ),//16
			NewLocPair( <-8115,5539,2470>, <0,-88,0> ),

			NewLocPair( <2007,23375,4190>, <0,45,0> ),//17
			NewLocPair( <3112,24544,4190>, <0,-135,0> ),

			NewLocPair( <28023,-5219,4248>, <0,179,0> ),//18
			NewLocPair( <26505,-5219,4248>, <0,0,0> ),

			NewLocPair( <-24643,11027,3090>,<0,0,0> ),//19zzt
			NewLocPair( <-23808,11104,3028>,<0,170,0> ),

			NewLocPair( <-16131,-18339,3583>,<0,-36,0> ),//20zzt
			NewLocPair( <-15046,-19175,3527>,<0,150,0> ),

			NewLocPair( <-9830,-25727,2579>,<0,-115,0> ),//21zzt
			NewLocPair( <-10110,-27197,2576>,<0,72,0> ),

			NewLocPair( <20278,11876,5078>,<0,-176,0> ),//22 zzt
			NewLocPair( <19507,11682,4936>,<0,0,0> ),

			NewLocPair( <10617,11637,5306>,<0,39,0> ),//23zzt
			NewLocPair( <10836,13212,5396>,<0,-82,0> ),
		]
		
		return allSoloLocations
	}	
	else if ( mapName == "mp_rr_canyonlands_staging" && g_bLGmode ) //_LG_duels
	{
		//waitingRoomLocation = NewLocPair( < 3477.74, -8544.55, -10252 >, < 356.203, 269.459, 0 >)  
		waitingRoomPanelLocation = NewLocPair( < 3486.38, -9283.15, -10252 >, < 0, 180, 0 >) //休息区观战面板

		allSoloLocations= [

			NewLocPair( < 1317.27, 10573.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.367, 0.169666, 0 > ),//1
			NewLocPair( < 1912.15, 10630.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.431, 180.377, 0 > ),
			
			
			NewLocPair( < 1314.7, 11484.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.433, 359.118, 0 > ),//2
			NewLocPair( < 1920.17, 11083.7, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.616, 179.015, 0 > ),
			
			
			NewLocPair( < 1342.6, 12083.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.021, 359.681, 0 > ),//3
			NewLocPair( < 1928.12, 12062, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.46, 179.056, 0 > ),
			
			
			NewLocPair( < 1334.54, 12767, 135.001 > + LG_DUELS_OFFSET_ORIGIN, < 359.376, 359.648, 0 > ),//4
			NewLocPair( < 1929.33, 12617.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.646, 179.52, 0 > ),
			
			
			NewLocPair( < 1314.61, 13608.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.413, 359.458, 0 > ),//5
			NewLocPair( < 1932.81, 13588.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.417, 179.147, 0 > ),
			
			
			NewLocPair( < 1327.13, 14445.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.142, 359.982, 0 > ),//6
			NewLocPair( < 1895.99, 14101.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.454, 179.149, 0 > ),
			
			
			NewLocPair( < 2027.17, 14255.7, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.44, 0.900257, 0 > ),//7
			NewLocPair( < 2705.93, 14519.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.557, 179.749, 0 > ),
						
			
			NewLocPair( < 2022.17, 13587.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.804, 1.26951, 0 > ),//8
			NewLocPair( < 2649.07, 13569.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.587, 177.486, 0 > ),
			
			
			NewLocPair( < 2012.83, 12907, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.71, 358.894, 0 > ),//9
			NewLocPair( < 2705.93, 12639.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.306, 179.909, 0 > ),
			
			
			NewLocPair( < 2007.38, 12065.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.02, 1.20616, 0 > ),//10
			NewLocPair( < 2705.93, 12187.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.205, 179.637, 0 > ),
						
			
			NewLocPair( < 2010.97, 11294.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.677, 1.92442, 0 > ),//11
			NewLocPair( < 2684.01, 11274.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.706, 181.528, 0 > ),
			
			
			NewLocPair( < 2018.2, 10553.4, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.365, 0.918914, 0 > ),//12
			NewLocPair( < 2695.21, 10658.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.73, 180.507, 0 > ),
			
			
			NewLocPair( < 3454.38, 10463.6, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.461, 179.844, 0 >),//13
			NewLocPair( < 2774.57, 10563.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.25, 359.569, 0 > ),
						
			
			NewLocPair( < 2789.48, 11318, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.431, 359.476, 0 > ),//14
			NewLocPair( < 3419.66, 11296.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.114, 178.214, 0 > ),
			
			
			NewLocPair( < 2851.9, 12073.4, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.097, 0.0967312, 0 > ),//15
			NewLocPair( < 3410.55, 11985.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.553, 178.984, 0 > ),
			
			
			NewLocPair( < 3434.33, 12949.8, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.217, 180.349, 0 > ),//16
			NewLocPair( < 2789.41, 12696.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.063, 0.618432, 0 > ),
						
			
			NewLocPair( < 2821.61, 13592.5, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.434, 0.300493, 0 > ),//17
			NewLocPair( < 3445.45, 13501.6, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.302, 178.999, 0 > ),
			
			
			NewLocPair( < 2785.1, 14336.5, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 357.755, 1.08752, 0 > ),//18
			NewLocPair( < 3418.27, 14335, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.706, 178.716, 0 > ),
			
			
			NewLocPair( < 3556.97, 14536.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.44, 359.719, 0 > ),//19
			NewLocPair( < 4190.3, 14080.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.096, 178.87, 0 > ),
						
			
			NewLocPair( < 3567.85, 13604.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.768, 359.636, 0 > ),//20
			NewLocPair( < 4201.19, 13668.7, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.71, 180.051, 0 > ),
			
			
			NewLocPair( < 3551.94, 13015.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.056, 359.814, 0 > ),//21
			NewLocPair( < 4194.56, 12673.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.854, 180.855, 0 > ),
			
			
			NewLocPair( < 3542.06, 11949.6, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.863, 0.431551, 0 > ),//22
			NewLocPair( < 4212.53, 12181.8, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.223, 179.777, 0 > ),
						
			
			NewLocPair( < 3535.76, 11498.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.982, 359.36, 0 > ),//23
			NewLocPair( < 4155.54, 11130.5, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.654, 179.863, 0 > ),
			
			
			NewLocPair( < 3542.66, 10485.4, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.779, 359.757, 0 > ),//24
			NewLocPair( < 4216.37, 10769.5, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.249, 180.085, 0 > ),
			
			
			NewLocPair( < 4312.77, 10552.7, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.922, 0.222934, 0 > ),//25
			NewLocPair( < 4934.16, 10569.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.363, 179.387, 0 > ),
						
			
			NewLocPair( < 4934.63, 11044.4, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.444, 179.237, 0 > ),//26
			NewLocPair( < 4293.06, 11584.1, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 359.283, 358.251, 0 > ),
			
			
			NewLocPair( < 4939.28, 12050.6, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.252, 178.744, 0 > ),//27
			NewLocPair( < 4317.15, 12075.5, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 357.813, 359.825, 0 > ),
			
			
			NewLocPair( < 4953.12, 12665.2, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.416, 179.383, 0 > ),//28
			NewLocPair( < 4288.89, 12679.3, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.572, 359.256, 0 > ),
						
			
			NewLocPair( < 4949.51, 13535, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.109, 179.168, 0 > ),//29
			NewLocPair( < 4334.56, 13790.7, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.745, 359.199, 0 > ),
			
			
			NewLocPair( < 4854.76, 14333.8, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.84, 179.242, 0 > ),//30
			NewLocPair( < 4449.29, 14355.9, 136.275 > + LG_DUELS_OFFSET_ORIGIN, < 358.114, 359.415, 0 > ),
			
		]
		
		return allSoloLocations
	}
	else if (mapName == "mp_rr_party_crasher")
	{
		//waitingRoomLocation = NewLocPair( < 3477.74, -8544.55, -10252 >, < 356.203, 269.459, 0 >)  
		waitingRoomPanelLocation = NewLocPair( < 1822, -3977, 626 >, < 0, 15, 0 > ) //休息区观战面板

		allSoloLocations= [

			NewLocPair( < -2053.13, 4360.61, 563.285 >, < 0, 186, 0 > ),
			NewLocPair( < -2958.06, 3402.03, 563.271 >, < 0, 85, 0 > ),
			
			NewLocPair( < -1387.71, 2184.46, 834.302 >, < 0, 40, 0 > ),
			NewLocPair( < -1050.73, 2471.19, 834.302 >, < 0, 220, 0 > ),
			
			NewLocPair( < -1774.73, 42.2706, 1177.18 >, < 0, 30, 0 > ),
			NewLocPair( < -875.26, 530.277, 1079.86 >, < 0, 208, 0 > ),
			
			NewLocPair( < -978.056, -28.7255, 1290.62 >, < 0, 133, 0 > ),
			NewLocPair( < -1421.04, 475.461, 1298.05 >, < 0, 305, 0 > ),
			
			NewLocPair( < 772.704, -1660.51, 835.302 >, < 0, 22, 0 > ),
			NewLocPair( < 1197.34, -1487.04, 835.302 >, < 0, 203, 0 > ),
			
			NewLocPair( < 1046.13, -3527.3, 563.272 >, < 0, 331, 0 > ),
			NewLocPair( < 2342.18, -3197.44, 563.285 >, < 0, 233, 0 > ),
			
			NewLocPair( < 2663.09, -487.083, 730.031 >, < 0, 109, 0 > ),
			NewLocPair( < 2512.93, -32.7122, 730.031 >, < 0, 290, 0 > ),
			
			NewLocPair( < 2837.64, -258.927, 930.031 >, < 0, 109, 0 > ),
			NewLocPair( < 2686.48, 186.067, 930.031 >, < 0, 288, 0 > ),
			
			NewLocPair( < 2013.12, 2245.02, 920.031 >, < 0, 300, 0 > ),
			NewLocPair( < 2550.29, 1371.93, 920.031 >, < 0, 121, 0 > ),
			
			NewLocPair( < 835.26, 2797.75, 940.031 >, < 0, 132, 0 > ),
			NewLocPair( < 544.371, 3121.64, 940.031 >, < 0, 313, 0 > ),
			
			NewLocPair( < 930.568, 3029.09, 740.031 >, < 0, 133, 0 > ),
			NewLocPair( < 582.145, 3424.91, 740.031 >, < 0, 311, 0 > ),
			
			NewLocPair( < 1843.89, 816.934, 703.031 >, < 0, 119, 0 > ),
			NewLocPair( < 1220.95, 1939.03, 703.031 >, < 0, 300, 0 > ),
			
			NewLocPair( < 1509.87, 195.799, 543.613 >, < 0, 181, 0 > ),
			NewLocPair( < 839.514, 191.83, 543.613 >, < 0, 0, 0 > ),
		
		]
		
		return allSoloLocations
	}
	else if (mapName == "mp_rr_olympus_mu1")
	{
		//waitingRoomLocation = NewLocPair( < 3477.74, -8544.55, -10252 >, < 356.203, 269.459, 0 >)  
		waitingRoomPanelLocation = NewLocPair( <665.5224, -19241.1816, -4947.88916>, <0, -97.6569595, 0> ) //休息区观战面板

		if( is3v3Mode() )
		{
			allSoloLocations = [
				// NewLocPair( <-20382.9375, 28349.0488, -6379.54199>, <0, 42.8024635, 0> ),
				// NewLocPair( <-15628.7354, 33786.6602, -6181.9043>, <0, -144.864426, 0> ),

				// NewLocPair( <-20105.1855, -1279.15027, -5568.2041>, <0, 149.361572, 0> ),
				// NewLocPair( <-26193.8652, 2219.52808, -5573.85596>, <0, -30.5185471, 0> ),
				
				// NewLocPair( <21201.8613, -14852.7305, -5032.22363>, <0, -78.5065842, 0> ),
				// NewLocPair( <21783.9785, -21842.8613, -5032.22363>, <0, 107.717316, 0> ),

				NewLocPair( <9436.18555, 28426.0469, -4654.91553>, <0, -127.501564, 0> ),
				NewLocPair( <3670.51611, 20282.0215, -5598.02393>, <0, 57.8940849, 0> )

			]
			 

		}
		else
		{
			allSoloLocations = [
				NewLocPair( <-16998.4922, 11897.5928, -6397.17383>, <0, 69.6194611, 0> ),
				NewLocPair( <-16332.7354, 13246.3271, -6399.63477>, <0, -115.500526, 0> )
			]
		}
	}
	else
	{
		return allSoloLocations
	}
	
	return allSoloLocations
}

array<LocPair> function FetchReturnAllPanelLocations()
{
	array<LocPair> panelLocations = []
	return panelLocations
}