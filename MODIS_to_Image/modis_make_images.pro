pro modis_make_images,infile,colorbar,land_index,ext=ext,enhance=enhance

;; Input file is Rayleigh corrected reflectance of MODIS
;; in Band 01-05
rrc = read_tiff(infile)
nland = n_elements(land_index)
;; test if image include valid pixels in the YS
idx_ys = where(rrc[3,*,*] lt 1.0,nys)
if nys lt 2e5 then return

read_png,colorbar,cb_image,r,g,b
r[236] = 255 & g[236]=255 & b[236]=255
r[237] = 102 & g[237]=102 & b[237]=102
r[238] = 0 & g[238]=0 & b[238]=0
cbtop=191 & cb_white=236 & cb_land=237 & cb_black=238

;loadct,13 & tvlct,rr,gg,bb,/get
;rr[251] = 255 & gg[251]=255 & bb[251]=255
;rr[252] = 102 & gg[252]=102 & bb[252]=102
;rr[253] = 0 & gg[253]=0 & bb[253]=0

basename = strmid(infile,0,14)
if ~keyword_set(ext) then ext='ys'

file_fai = basename+'.fai.'+ext+'.tif'
file_di = basename+'.di.'+ext+'.tif'
file_vbfah = basename+'.vbfah.'+ext+'.tif'
file_rgb_png = basename +'.rgb.'+ext+'.png'
file_frgb_png = basename +'.false.rgb.'+ext+'.png'
file_fai_png = basename +'.fai.'+ext+'.png'
file_ndvi_png = basename +'.ndvi.'+ext+'.png'
file_di_png = basename +'.di.'+ext+'.png'
file_vbfah_png = basename+'.vbfah.'+ext+'.png'
file_rgb_thumb = basename+'.rgb.'+ext+'.thumb.png'
file_fai_thumb = basename+'.fai.'+ext+'.thumb.png'
file_ndvi_thumb = basename+'.ndvi.'+ext+'thumb.png'
;; reading pallet file


fai = reform(rrc[3,*,*]-rrc[2,*,*]-(rrc[4,*,*]-rrc[2,*,*])*(859.0-645.0)/(1240.0-645.0))
dims = size(fai,/dimensions)
ncol = dims[0] & nrow = dims[1]
fai_scl=bytscl(fai,min=-0.015,max=0.05,top=cbtop)
bad_index = where(reform(rrc[0,*,*]) lt 0 or reform(rrc[0,*,*]) gt 1.0,npx)
if npx gt 0 then fai_scl[bad_index] = cb_black
if nland gt 0 then fai_scl[land_index]=cb_land
fai_thumb = congrid(fai_scl,200,200)

;vbfah = reform(rrc[3,*,*]-rrc[1,*,*]+(rrc[1,*,*]-rrc[2,*,*])*(859.0-555.0)/(2*859.0-645.0-555))
;vbfah_scl=bytscl(vbfah,min=-0.025,max=0.03,top=cbtop)
;if npx gt 0 then vbfah_scl[bad_index] = cb_black
;if nland gt 0 then vbfah_scl[land_index]=cb_land


ndvi = reform((rrc[3,*,*]-rrc[2,*,*])/(rrc[3,*,*]+rrc[2,*,*]))
ndvi_scl=bytscl(ndvi,min=-0.25,max=0.3,top=cbtop)
if npx gt 0 then ndvi_scl[bad_index] = cb_black
if nland gt 0 then ndvi_scl[land_index]=cb_land
ndvi_thumb = congrid(ndvi,200,200)

;di = reform(rrc[3,*,*]-rrc[2,*,*])
;di_scl=bytscl(di,min=-0.025,max=0.03,top=cbtop)
;if npx gt 0 then di_scl[bad_index] = cb_black
;if nland gt 0 then di_scl[land_index]=cb_land

rgb_image = bytarr(3,ncol,nrow) & false_image = rgb_image
rgb_image[0,*,*]=bytscl(reform(rrc[2,*,*]),min=0.0, max=0.2, TOP=cbtop)
rgb_image[1,*,*]=bytscl(reform(rrc[1,*,*]),min=0.0, max=0.17, TOP=cbtop)
rgb_image[2,*,*]=bytscl(reform(rrc[0,*,*]),min=0.0, max=0.2, TOP=cbtop)
rgb_thumb = congrid(rgb_image,3,200,200)

false_image[0,*,*]=bytscl(reform(rrc[2,*,*]),min=0.0, max=0.20, TOP=cbtop)
false_image[1,*,*]=bytscl(reform(rrc[3,*,*]),min=0.0, max=0.171, TOP=cbtop)
false_image[2,*,*]=bytscl(reform(rrc[0,*,*]),min=0.0, max=0.192, TOP=cbtop)

if keyword_set(enhance) then begin
  file_frgb_enhance_png = basename +'.false.rgb.enhance.'+ext+'.png'
  false_enhance_image=modis_rgb_enhance(reform(rrc[2,*,*]),reform(rrc[3,*,*]),reform(rrc[0,*,*]),RANGE=[0,0.2])
  write_png,file_frgb_enhance_png,false_enhance_image,/order
endif

write_tiff,file_fai,fai,geotiff=geotiff,/float
;write_tiff,file_di,di,geotiff=geotiff,/float
;write_tiff,file_vbfah,vbfah,geotiff=geotiff,/float
write_png,file_fai_png,fai_scl,r,g,b,/order
;write_png,file_vbfah_png,vbfah_scl,r,g,b,/order
write_png,file_ndvi_png,ndvi_scl,r,g,b,/order
;write_png,file_di_png,di_scl,r,g,b,/order
write_png,file_rgb_png,rgb_image,/order
write_png,file_frgb_png,false_image,/order
write_png,file_fai_thumb,fai_thumb,r,g,b,/order
write_png,file_rgb_thumb,rgb_thumb,r,g,b,/order
write_png,file_ndvi_png,ndvi_thumb,r,g,b,/order

end
