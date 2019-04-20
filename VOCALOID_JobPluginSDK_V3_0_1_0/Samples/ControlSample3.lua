--
-- ControlSample3.lua
-- コントロールパラメータの追加/削除のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "コントロールパラメータの追加/削除のサンプル",
        comment       = "コントロールパラメータの追加/削除のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{98EBB5BE-A7D2-447b-80B8-79603BEA7B79}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }
    
    return myManifest
end


--
-- VOCALOID3 Jobプラグインスクリプトのエントリポイント.
--
function main(processParam, envParam)
	-- 実行時に渡された処理条件パラメータを取得します.
	local beginPosTick = processParam.beginPosTick	-- 選択範囲の始点時刻（ローカルTick）.
	local endPosTick   = processParam.endPosTick	-- 選択範囲の終点時刻（ローカルTick）.
	local songPosTick  = processParam.songPosTick	-- カレントソングポジション時刻（ローカルTick）.

	-- 実行時に渡された実行環境パラメータを取得します.
	local scriptDir  = envParam.scriptDir	-- Luaスクリプトが配置されているディレクトリパス（末尾にデリミタ "\" を含む）.
	local scriptName = envParam.scriptName	-- Luaスクリプトのファイル名.
	local tempDir    = envParam.tempDir		-- Luaプラグインが利用可能なテンポラリディレクトリパス（末尾にデリミタ "\" を含む）.


	local control = {}
	local controlList = {}
	local controlNum
	local retCode
	local idx


	-- ダイナミクスコントロールイベントを取得します.
	retCode = VSSeekToBeginControl("DYN")
	idx = 1
	retCode, control = VSGetNextControl("DYN")
	while (retCode == 1) do
		controlList[idx] = control
		retCode, control = VSGetNextControl("DYN")
		idx = idx + 1
	end
	controlNum = table.getn(controlList)

	-- 取得したダイナミクスコントロールイベントを全部削除します.
	for idx = 1, controlNum do
		retCode = VSRemoveControl(controlList[idx])
	end

	-- 取得したダイナミクスコントロールイベントを一定間隔で間引きます.
	-- 平均値のイベントを挿入することで,結果として間引きになります.
	local pos1 = 1
	local pos2
	for pos2 = 2, controlNum do
		local control1 = {}
		local control2 = {}
		control1 = controlList[pos1]
		control2 = controlList[pos2]
		
		local dt = control2.posTick - control1.posTick
		if (32 < dt) then
			local newControl = {}
			newControl.posTick = (control1.posTick + control2.posTick) / 2
			newControl.value   = (control1.value   + control2.value) / 2
			newControl.type    = "DYN"
			retCode = VSInsertControl(newControl)
			pos1 = pos2
		end
	end


	-- 正常終了.
	return 0
end
