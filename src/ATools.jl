module ATools


include("math.jl")
include("util.jl")
include("histos.jl")
include("fits.jl")
include("raytracing.jl")
include("io.jl")
include("reco.jl")

export in_range,gline2p, rxy,phixy,fphi,dxyz,mean_std,fit,
       fit_pol1, fit_pol2,fit_pol3, fit_gauss,fit_gauss_fm,
       fitg1, fitg2, fit_profile, plot_fit_gauss  #math
export select_event,select_by_index,select_by_column_value,
       select_by_column_value_lt, select_by_column_value_le,
       select_by_column_value_gt, select_by_column_value_ge,
       select_by_column_value_interval,select_by_column_value_closed_interval,
       select_by_column_value_closed_left_interval,select_by_column_value_closed_right_interval,
       select_by_index,find_max_xy   #util
export hist1d, edges, centers, hist2d, p1df #histos
export readdf, read_abc, readh5_dset, readh5_todf, read_evtpar
#export lfit, fit_pol1, fit_pol2,fit_pol3, fit_gauss,fit_gauss_fm,
#       fitg1, fitg2, fit_profile #fits


end
