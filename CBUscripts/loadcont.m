% UNCOMMENT AS NEEDED
condlists = {
%     %sensor level
    {'ld','ls','gd','gs','od','oc'} [50 650]

%     %source level
%     {'ld','ls'} [100 100]
%     {'gd','gs'} 450 + [-150 150]
%     {'od','oc'} [170 170]

    %to generate images for plotting time dimension
%     {'ld','ls','gd','gs','od','oc'} [-200 700]
    };

contrasts = {
    struct('name','global_ld-global_ls','type','F','c', [1   -1  0   0   0   0   0   0   0   0   0   0 ])
    struct('name','global_gd-global_gs','type','F','c', [0   0   1   -1  0   0   0   0   0   0   0   0 ])
    struct('name','global_od-global_oc','type','F','c', [0   0   0   0   1   -1  0   0   0   0   0   0 ])
    struct('name','visual_ld-visual_ls','type','F','c', [0   0   0   0   0   0   1   -1  0   0   0   0 ])
    struct('name','visual_gd-visual_gs','type','F','c', [0   0   0   0   0   0   0   0   1   -1  0   0 ])
    struct('name','visual_od-visual_oc','type','F','c', [0   0   0   0   0   0   0   0   0   0   1   -1])
    struct('name','local_dev-local-std',   'type','F','c', [1   -1  0   0   0   0   1   -1  0   0   0   0 ])
    struct('name','global_dev-global_std', 'type','F','c', [0   0   1   -1  0   0   0   0   1   -1  0   0 ])
    struct('name','omission-omission_ctrl','type','F','c', [0   0   0   0   1   -1  0   0   0   0   1   -1])
    struct('name','auditory-visual_local',    'type','F','c', [1   1   0   0   0   0   -1  -1  0   0   0   0 ])
    struct('name','auditory-visual_global',   'type','F','c', [0   0   1   1   0   0   0   0   -1  -1  0   0 ])
    struct('name','auditory-visual_omission', 'type','F','c', [0   0   0   0   1   1   0   0   0   0   -1  -1])
    struct('name','attention-local_interaction',   'type','F','c', [1   -1  0   0   0   0   -1  1   0   0   0   0 ])
    struct('name','attention-global_interaction',  'type','F','c', [0   0   1   -1  0   0   0   0   -1  1   0   0 ])
    struct('name','attention-omission_interaction','type','F','c', [0   0   0   0   1   -1  0   0   0   0   -1  1 ])
    };