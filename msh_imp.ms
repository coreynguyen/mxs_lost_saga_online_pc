clearlistener()
try(DestroyDialog lostsagaonline_imp)catch(lostsagaonline_imp)
rollout lostsagaonline_imp "Lost Sage Online" (
	
	button btn1 "Import" width:120 height:30
	checkbox chk1 "Clear Scene" checked:true
	spinner spn1 "Scale" range:[-999999999.0, 999999999.0, 1.0] type:#float scale:0.01 align:#left
	label lbl1 ""
	group "About" (
		hyperLink lb5 "Author: mariokart64n" address:"mailto:mario_kart64n@hotmail.com"
		label lb3 "Date: April ‎29, ‎2020" align:#left
		)
	
	struct mshfile_mat (
		vert_pos = 0,
		vert_count = 0,
		face_pos = 0,
		face_count = 0,
		fn read_mat &f = (
			vert_pos = readlong f #unsigned
			vert_count = readlong f #unsigned
			face_pos = readlong f #unsigned
			face_count = readlong f #unsigned
			)
		)
	
	struct mshfile (
		filetype = 0,	-- 0x0048534D, msh
		unk01 = 0,	-- 2000, version?
		hasBones = 0,
		unk03 = 0, -- some unique id?
		boundMin = [0.0, 0.0, 0.0],
		boundMax = [0.0, 0.0, 0.0],
		boundSphereRadius = 0.0,
		materialCount = 0,
		mats = #(),
		boneNames = #(),
		boneCount = 0,
		vertCount = 0,
		vertPos = 0,
		normPos = 0,
		uvw0Pos = 0,
		faceCount = 0,
		facePos = 0,
		weightPos = 0,
		fn read_string &f = (
			local str = "", i = 1
			for i = 1 to (readlong f #unsigned) do (
				str+=bit.IntAsChar (readbyte f #unsigned)
				)
			str
			),
		fn read_msh &f = (
			local i = 1
			filetype = readlong f #unsigned
			if filetype == 0x0048534D then (
				unk01 = readlong f #unsigned
				hasBones = readlong f #unsigned
				unk03 = readlong f #unsigned
				boundMin = [readfloat f, readfloat f, readfloat f]
				boundMax = [readfloat f, readfloat f, readfloat f]
				boundSphereRadius = readfloat f
				materialCount = readlong f #unsigned
				if materialCount > 0 do (
					mats[materialCount] = mshfile_mat()
					for i = 1 to materialCount do (
						mats[i] = mshfile_mat()
						mats[i].read_mat(f)
						)
					)
				vertCount = readlong f #unsigned
				vertPos = ftell f
				fseek f (vertCount * 0x0C) #seek_cur
				normPos = ftell f
				fseek f (vertCount * 0x0C) #seek_cur
				uvw0Pos = ftell f
				fseek f (vertCount * 0x08) #seek_cur
				if hasBones == 1 do (
					boneCount = readlong f #unsigned
					if boneCount > 0 do boneNames[boneCount] = ""
					for i = 1 to boneCount do (
						boneNames[i] = read_string(f)
						)
					weightPos = ftell f
					fseek f (vertCount * 0x20) #seek_cur
					)
				faceCount = readlong f #unsigned
				facePos = ftell f
				) else (messagebox "Unsupported file")
			)
		)
	
	fn readMsh file clear_scene:true mscale:1.0 = (
		local f = undefined, msh = undefined
		local i = 1, m = mshfile(), v = 1
		local normArray = #(), vertArray = #(), faceArray = #(), uvw0Array = #()
		local b = undefined
		f = try(fopen file "rbS")catch(undefined)
		
		if clear_scene do (delete objects)
		
		if f != undefined then (
			m.read_msh(f)
			for i = 1 to m.materialCount do (
				vertArray = #()
				fseek f (m.vertPos + (m.mats[i].vert_pos * 0x0C)) #seek_set
				for v = 1 to m.mats[i].vert_count do (
					append vertArray ([readfloat f, readfloat f, readfloat f] * mscale)
					)
				normArray = #()
				fseek f (m.normPos + (m.mats[i].vert_pos * 0x0C)) #seek_set
				for v = 1 to m.mats[i].vert_count do (
					append normArray [readfloat f, readfloat f, readfloat f]
					)
				uvw0Array = #()
				fseek f (m.uvw0Pos + (m.mats[i].vert_pos * 0x08)) #seek_set
				for v = 1 to m.mats[i].vert_count do (
					append uvw0Array [readfloat f, 1.0 - (readfloat f), 0]
					)
				faceArray = #()
				fseek f (m.facePos + (m.mats[i].face_pos * 0x02)) #seek_set
				for v = 1 to m.mats[i].face_count do (
					append faceArray (
						[readshort f #unsigned, \
						readshort f #unsigned, \
						readshort f #unsigned] + 1 - m.mats[i].vert_pos
						)
					)
				if m.hasBones == 1 do (
					fseek f (m.weightPos + (m.mats[i].vert_pos * 0x20)) #seek_set
					for v = 1 to m.mats[i].vert_count do (
						[readfloat f, readfloat f, readfloat f, readfloat f] -- weight
						[readfloat f, readfloat f, readfloat f, readfloat f] -- boneids?
						)
					)
				msh = mesh vertices:vertArray faces:faceArray
				msh.wirecolor = random white black
				)
			fclose f
			) else (messagebox "Invalid File")
		)
	
	on btn1 pressed do (
		readMsh (
			GetOpenFileName types:"All Supported Formats (*.msh)|*.MSH|All files (*.*)|*.*|"
			) clear_scene:chk1.checked mscale:spn1.value
		)
	)
CreateDialog lostsagaonline_imp
/*
lostsagaonline_imp.readMsh (
	GetOpenFileName types:"All Supported Formats (*.msh)|*.MSH|All files (*.*)|*.*|"
	)
*/