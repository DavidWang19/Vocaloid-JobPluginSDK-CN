--
-- 選択範囲の削除.
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "Delete Selection",
        comment       = "Delete selected region and shift the folloing events left.",
        author        = "Yamaha Corporation",
        pluginID      = "{6D9E75F9-8167-401c-9A0E-CA6A994F890E}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }
    
    return myManifest
end


-- ノートリスト
noteList = {}

-- コントロールパラメータリスト = {}
controlList = {}
controlListMap = {
	{ type = "DYN", controlList = {} },	-- ダイナミクス.
	{ type = "BRE", controlList = {} },	-- ブレシネス.
	{ type = "BRI", controlList = {} },	-- ブライトネス.
	{ type = "CLE", controlList = {} },	-- クリアネス.
	{ type = "GEN", controlList = {} },	-- ジェンダーファクター.
	{ type = "PIT", controlList = {} },	-- ピッチベンド.
	{ type = "PBS", controlList = {} },	-- ピッチベンドセンシティビティー.
	{ type = "POR", controlList = {} }	-- ポルタメントタイミング.
}
controlTypeIDNum = table.getn(controlListMap)


--
-- スクリプトのエントリポイント関数.
--
function main(processParam, envParam)
	-- 実行時に渡されたパラメータを取得する.
	local beginPosTick = processParam.beginPosTick	-- 選択範囲の始点時刻（ローカルTick）.
	local endPosTick   = processParam.endPosTick	-- 選択範囲の終点時刻（ローカルTick）.
	local songPosTick  = processParam.songPosTick	-- カレントソングポジション時刻（ローカルTick）.

	-- 実行時に渡された実行環境パラメータを取得する.
	local scriptDir  = envParam.scriptDir	-- Luaスクリプトが配置されているディレクトリパス（末尾にデリミタ "\" を含む）.
	local scriptName = envParam.scriptName	-- Luaスクリプトのファイル名.
	local tempDir    = envParam.tempDir		-- Luaプラグインが利用可能なテンポラリディレクトリパス（末尾にデリミタ "\" を含む）.

	local startPosTick
	local delDuration
	local note = {}
	local control = {}
	local field = {}
	local noteCount
	local controlCount
	local dlgStatus
	local retCode
	local type
	local idx

	-- パラメータ入力ダイアログのウィンドウタイトルを設定する.
	VSDlgSetDialogTitle("Delete Selection")
	
	-- ダイアログにフィールドを追加する.
	field.name       = "startPosTick"
	field.caption    = "Start time (Tick)"
	field.initialVal = beginPosTick
	field.type       = 0
	dlgStatus = VSDlgAddField(field)
	
	field.name       = "endPosTick"
	field.caption    = "End time (Tick)"
	field.initialVal = endPosTick
	field.type       = 0
	dlgStatus = VSDlgAddField(field)

	-- ダイアログから入力値を取得する.
	dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return 0
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return 1
	end
	
	-- ダイアログから入力値を取得する.
	dlgStatus, startPosTick = VSDlgGetIntValue("startPosTick")
	dlgStatus, endPosTick  = VSDlgGetIntValue("endPosTick")
	local delDuration = endPosTick - startPosTick

	-- ノートを取得する.
	VSSeekToBeginNote()
	idx = 1
	retCode, note = VSGetNextNote()
	while (retCode == 1) do
		noteList[idx] = note
		retCode, note = VSGetNextNote()
		idx = idx + 1
	end
	noteCount = table.getn(noteList)

	-- 削除区間内のノートを削除する.
	for idx = 1, noteCount do
		if ((startPosTick <= noteList[idx].posTick) and (noteList[idx].posTick <= endPosTick)) then
			VSRemoveNote(noteList[idx])
		end
	end

	-- ノートをシフトする.
	for idx = 1, noteCount do
		if (endPosTick <= noteList[idx].posTick) then
			noteList[idx].posTick = noteList[idx].posTick - delDuration
			VSUpdateNote(noteList[idx])
		end
	end
	
	-- コントロールパラメータを取得する.
	for type = 1, controlTypeIDNum do
		retCode = VSSeekToBeginControl(controlListMap[type].type)
		idx = 1
		retCode, control = VSGetNextControl(controlListMap[type].type)
		while (retCode == 1) do
			controlListMap[type].controlList[idx] = control
			retCode, control = VSGetNextControl(controlListMap[type].type)
			idx = idx + 1
		end
	end
	
	-- 削除区間内のコントロールパラメータを削除する.
	for type = 1, controlTypeIDNum do
		controlCount = table.getn(controlListMap[type].controlList)
		for idx = 1, controlCount do
			if ((startPosTick <= controlListMap[type].controlList[idx].posTick) and
				(controlListMap[type].controlList[idx].posTick <= endPosTick)) then
				VSRemoveControl(controlListMap[type].controlList[idx])
			end
		end
	end

	-- コントロールパラメータをシフトする.
	for type = 1, controlTypeIDNum do
		controlCount = table.getn(controlListMap[type].controlList)
		for idx = 1, controlCount do
			if (endPosTick <= controlListMap[type].controlList[idx].posTick) then
				controlListMap[type].controlList[idx].posTick = controlListMap[type].controlList[idx].posTick - delDuration
				VSUpdateControl(controlListMap[type].controlList[idx])
			end
		end
	end
	
	-- 正常終了.
	return 0
end
