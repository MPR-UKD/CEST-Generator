function [Z, x] = generate_Z_spectrum(Scanner_parameter, CEST_Parameter, n)

    step_size = (2 * Scanner_parameter.ppm_range) / (n -1);


    %% BASIC SIMULATION PARAMETERS
    Sim=init_Sim(struct());
    Sim.analytic          = 1;                % calculate analtical solution? 1=yes, 0=no
    Sim.numeric           = 0;                % calculate numerical solution? 1=yes, 0=no
    Sim.all_offsets       = 1;                % 1 = z-spectrum, 0 = simulate only +- offset, 2 = on-resonant
    Sim.offset            = Scanner_parameter.ppm_range;                % offset range in ppm
    Sim.n_cest_pool       = CEST_Parameter.n_cest_pool;                % number of CEST/NOE pools (CEST pools: B,D,E,F,G...)


    %% SEQUENCE AND SCANNER PARAMETERS

    Sim.FREQ          =     3*gamma_;           % frequency (=B0[T] * gamma)
    Sim.B1            =     Scanner_parameter.B1;                 % standard B1 value in µT
    Sim.Trec          =     Scanner_parameter.Trec;                  % standard recover time in s
    Sim.Zi            =     0;                  % initial magnetisation (should be between -1 and +1)
    Sim.shape         =     'gauss';            % cases: SPINLOCK, seq_gauss, block, AdiaSL, AdiaSinCos, AdiaInversion,
                                                % block_trap, gauss, sech, sinc_1, sinc_2, sinc_3, sinc_4
    Sim.pulsed        =     1;                  % 0 = cw saturation, 1 = pulsed saturation

    % settings for pulsed saturation
    Sim.n     = Scanner_parameter.n;              % number of saturation pulses
    Sim.tp    = Scanner_parameter.tp;            % saturation time per pulse in s
    Sim.DC    = 0.50;             % duty cycle

    
    %% CHOOSE TISSUE-TYPE AND CEST-AGENT AND LOAD PARAMETERS WITH getSim

    % Pool system parameters  
    % water pool A
    a = 0.7;
    b = 1.3;
    r = a + (b-a).*rand(100,1);
    Sim.dwA=CEST_Parameter.dwA * r(1); 
    Sim.R1A=CEST_Parameter.R1A * r(2);   
    Sim.R2A=CEST_Parameter.R2A * r(3); 

    a = 0.7;
    b = 1.3;
    r = a + (b-a).*rand(100,1);
    % first CEST pool B
    Sim.fB=CEST_Parameter.fB * r(4);  
    Sim.kBA=CEST_Parameter.kBA * r(5); 
    Sim.dwB=CEST_Parameter.dwB * r(6);  
    Sim.R1B=CEST_Parameter.R1B * r(7);
    Sim.R2B=CEST_Parameter.R2B * r(8); 

    % third CEST pool D
    Sim.fD=CEST_Parameter.fD;  
    Sim.kDA=CEST_Parameter.kDA;   
    Sim.dwD=-CEST_Parameter.dwD;    
    Sim.R1D=CEST_Parameter.R1D;     
    Sim.R2D=CEST_Parameter.R2D;     
    
    % forth CEST pool E
    Sim.fE=CEST_Parameter.fE;
    Sim.kEA=CEST_Parameter.kEA; 
    Sim.dwE=-CEST_Parameter.dwE;
    Sim.R1E=CEST_Parameter.R1E;
    Sim.R2E=CEST_Parameter.R2E;
    
    % fifth CEST pool F
    Sim.fF=CEST_Parameter.fF; 
    Sim.kFA=CEST_Parameter.kFA; 
    Sim.dwF=-CEST_Parameter.dwF;
    Sim.R1F=CEST_Parameter.R1F;
    Sim.R2F=CEST_Parameter.R2F;

    Sim.n_cest_pool=CEST_Parameter.n_cest_pool;
    Sim.MT        = 0; %CEST_Parameter.MT; 


    %MT
    %Sim.MT                = 0;                % 1 = with MT pool (pool C), 0 = no MT pool
    %Sim.MT_lineshape      = 'Gaussian';       % MT lineshape - cases: SuperLorentzian, Gaussian, Lorentzian
    %Sim.R1C=1;
    %Sim.fC=0.05;
    %Sim.R2C=109890;  % 1/9.1µs
    %Sim.kCA=40; Sim.kAC=Sim.kCA*Sim.fC;

    SimStart          = Sim;

    %% CHOOSE PARAMETER'S VALUES TO BE SIMULATED
    % !!! dont delete parameters - just comment them out !!!
    clear Space
    % settings for all_offsets = 1 (complete Z-spectrum)
    Space.tp    = [Scanner_parameter.tp];

    names = fieldnames(Space);

    for jj = 1:numel(names)
        Sim       = SimStart;   % set back to standard Parameter
        field     = names{jj}; 

        for ii = 1:numel(Space.(field))

            % do NOT change
            Sim.(field)   = Space.(field)(ii);
            Sim.kAB = Sim.kBA*Sim.fB;
            Sim.kAC = Sim.kCA*Sim.fC;
            Sim.kAD = Sim.kDA*Sim.fD;
            Sim.kAE = Sim.kEA*Sim.fE;
            Sim.kAF = Sim.kFA*Sim.fF;
            Sim.kAG = Sim.kGA*Sim.fG;
            Sim.td  = calc_td(Sim.tp,Sim.DC);
            Sim.Zi= 1- (1-SimStart.Zi)*exp(-Sim.R1A*Sim.Trec);

            % adjust your spectral resolution here
            Sim.xZspec  = [Sim.dwA-Sim.offset:step_size:Sim.dwA+Sim.offset];
            Sim.xxZspec = [Sim.dwA-Sim.offset:step_size:Sim.dwA+Sim.offset];

            % do NOT change
            if Sim.numeric && Sim.analytic
                NUMERIC_SPACE.(field){ii} = NUMERIC_SIM(Sim);
                ANALYTIC_SPACE.(field){ii} = ANALYTIC_SIM(Sim);
            elseif Sim.numeric && ~Sim.analytic
                NUMERIC_SPACE.(field){ii} = NUMERIC_SIM(Sim);
                ANALYTIC_SPACE = NUMERIC_SPACE;
            elseif ~Sim.numeric && Sim.analytic
                ANALYTIC_SPACE.(field){ii} = ANALYTIC_SIM(Sim);
                NUMERIC_SPACE = ANALYTIC_SPACE;
            end
        end
    end

    clear ii jj names field


    %% PLOT SIMULATED ASYM- AND Z-SPECTRA
    % - numerical solutions are displayed as diamonds
    % - analytical solutions are displayed as solid lines
    %Sim.modelfield = 'zspec'; %standard value = 'zspec'
    %PLOT_SPACE(Sim,Space,NUMERIC_SPACE,ANALYTIC_SPACE);
    
    %Z = ANALYTIC_SPACE.tp{1, 1}.zspec;
    %x = ANALYTIC_SPACE.tp{1, 1}.x;
    
    Z = NUMERIC_SPACE.tp{1, 1}.zspec;
    x = NUMERIC_SPACE.tp{1, 1}.x;
end