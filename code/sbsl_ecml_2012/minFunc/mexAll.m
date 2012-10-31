% KPM
fprintf('Compiling KPM files...\n');
mex KPM/repmatC.c

% minFunc
fprintf('Compiling minFunc files...\n');
mex minFunc/lbfgsC.c

% UGM
fprintf('Compiling UGM files...\n');
mex -IUGM/mex UGM/mex/UGM_makeNodePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_makeEdgePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_Decode_ICMC.c
mex -IUGM/mex UGM/mex/UGM_Infer_LBPC.c
mex -IUGM/mex UGM/mex/UGM_Loss_subC.c
mex -IUGM/mex UGM/mex/UGM_PseudoLossC.c
mex -IUGM/mex UGM/mex/UGM_updateGradientC.c





