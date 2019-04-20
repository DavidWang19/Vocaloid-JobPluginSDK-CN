--
-- ControlSample1.lua
-- コントロールパラメータの取得のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "コントロールパラメータの取得のサンプル",
        comment       = "コントロールパラメータの取得のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{5F2176EE-2B4A-44ea-89B0-B7687085749F}",
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


	local retCode
	local controlVal = 0
	local controlMin = 128
	local controlMax = 0
	local controlAvg = 0


	-- 選択範囲のダイナミクスコントロールイベントの最大/最小/平均値を求めます.
	for posTick = beginPosTick, endPosTick do
		retCode, controlVal = VSGetControlAt("DYN", posTick)
		
		if (controlVal < controlMin) then
			controlMin = controlVal
		end
		if (controlMax < controlVal) then
			controlMax = controlVal
		end
		
		controlAvg = controlAvg + controlVal
	end
	
	if (beginPosTick < endPosTick) then
		controlAvg = controlAvg / (endPosTick - beginPosTick)
	else
		-- 平均値を求められません.
		controlAvg = -1
	end


	-- 計算結果をメッセージボックスへ表示します.
	local msg
	msg =
		"選択範囲のダイナミクスコントロールイベントの,\n" ..
		"  最大値 = [" .. controlMax ..
		"]\n  最小値 = [" .. controlMin ..
		"]\n  平均値 = [" .. controlAvg ..
		"]\nです."
	VSMessageBox(msg, 0)


	-- 正常終了.
	return 0
end
