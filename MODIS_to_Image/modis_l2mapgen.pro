pro modis_l2mapgen,l2file,SeaDAS=SeaDAS,ext=ext

;; plot and map MODIS l2 products using l2mapgen

basename = strmid(l2file,0,14)
if ~keyword_set(ext) then ext='ys'
if n_elements(SeaDAS) eq 0 then SeaDAS="/opt/SeaDAS"

file_sst_png = basename +'.sst.'+ext+'.png'
file_sst_thumb = basename +'.sst.'+ext+'.thumb.png'
file_ipar_png = basename +'.ipar.'+ext+'.png'
file_ipar_thumb = basename +'.ipar.'+ext+'.thumb.png'
file_chla_png = basename +'.chla.'+ext+'.png'
file_chla_thumb = basename +'.chla.'+ext+'.thumb.png'
;; reading pallet file

cmd1 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_sst_png+$
    ' prod=sst apply_pal=1 mask=1 datamin=0 datamax=32 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=2222 threshold=0 outmode=2'
cmd2 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_ipar_png+$
    ' prod=ipar apply_pal=1 mask=1 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=2222 threshold=0 outmode=2'
cmd3 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_chla_png+$
    ' prod=chlor_a apply_pal=1 mask=1 datamin=0 datamax=32 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=2222 threshold=0 outmode=2'
cmd4 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_sst_thumb+$
    ' prod=sst apply_pal=1 mask=1 datamin=0 datamax=32 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=200 threshold=0 outmode=2'
cmd5 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_ipar_thumb+$
    ' prod=ipar apply_pal=1 mask=1 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=200 threshold=0 outmode=2'
cmd6 = SeaDAS+'l2mapgen ifile='+l2file+' ofile='+file_chla_thumb+$
    ' prod=chlor_a apply_pal=1 mask=1 datamin=0 datamax=32 stype=1 east=123 west=118 south=33 north=38'+$
      ' width=200 threshold=0 outmode=2'

spawn,cmd1
spawn,cmd2
spawn,cmd3
spawn,cmd4
spawn,cmd5
spawn,cmd6

end
