--
-- ControlSample2.lua
-- コントロールパラメータの取得/更新のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "コントロールパラメータの取得/更新のサンプル",
        comment       = "コントロールパラメータの取得/更新のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{A00AF690-A52F-4f3a-AE29-2D6EAE732907}",
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

	-- 取得したダイナミクスコントロールイベントへゆらぎを付与します.
	local seed = os.time()
	math.randomseed(seed)
	for idx = 1, controlNum do
		local randControl = {}
		randControl = controlList[idx]
		
		randControl.value = randControl.value + math.random()*5.0
		
		retCode = VSUpdateControl(randControl)
	end


	-- 正常終了.
	return 0
end
