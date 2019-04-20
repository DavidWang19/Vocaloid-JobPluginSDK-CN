--
-- マスタトラック情報取得のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "マスタトラック情報取得のサンプル",
        comment       = "マスタトラック情報取得のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{46ED0A77-73AD-4042-8CB6-D7D666847E66}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }
    
    return myManifest
end


--
-- VOCALOID3 Jobプラグインスクリプトのエントリポイント.
--
function main(processParam, envParam)
	-- 実行時に渡されたパラメータを取得します.
	local beginPosTick = processParam.beginPosTick	-- 選択範囲の始点時刻（ローカルTick）.
	local endPosTick   = processParam.endPosTick	-- 選択範囲の終点時刻（ローカルTick）.
	local songPosTick  = processParam.songPosTick	-- カレントソングポジション時刻（ローカルTick）.

	-- 実行時に渡された実行環境パラメータを取得します.
	local scriptDir  = envParam.scriptDir	-- Luaスクリプトが配置されているディレクトリパス（末尾にデリミタ "\" を含む）.
	local scriptName = envParam.scriptName	-- Luaスクリプトのファイル名.
	local tempDir    = envParam.tempDir		-- Luaプラグインが利用可能なテンポラリディレクトリパス（末尾にデリミタ "\" を含む）.


	local tempo       = {}
	local tempoList   = {}
	local tempoNum

	local timeSig     = {}
	local timeSigList = {}
	local timeSigNum

	local retCode
	local idx
	local msg


	-- テンポを取得します.
	VSSeekToBeginTempo()
	idx = 1
	retCode, tempo = VSGetNextTempo()
	while (retCode == 1) do
		tempoList[idx] = tempo
		retCode, tempo = VSGetNextTempo()
		idx = idx + 1
	end
	tempoNum = table.getn(tempoList)

	-- 取得したテンポをメッセージボックスへ表示します.
	for idx = 1, tempoNum do
		msg =
			"取得したテンポは,\n" ..
			"  posTick = [" .. tempoList[idx].posTick ..
			"]\n  テンポ = [" .. tempoList[idx].tempo ..
			"]\nです.続けますか?"
		retCode = VSMessageBox(msg, 4)	-- MB_YESNO
		if (retCode == 7) then			-- IDNO
			-- 「いいえ」を選んだので終了します.
			return 0
		end
	end


	-- 拍子を取得します.
	VSSeekToBeginTimeSig()
	idx = 1
	retCode, timeSig = VSGetNextTimeSig()
	while (retCode == 1) do
		timeSigList[idx] = timeSig
		retCode, timeSig = VSGetNextTimeSig()
		idx = idx + 1
	end
	timeSigNum = table.getn(timeSigList)

	-- 取得した拍子をメッセージボックスへ表示します.
	for idx = 1, timeSigNum do
		msg =
			"取得した拍子は,\n" ..
			"  posTick = [" .. timeSigList[idx].posTick ..
			"]\n  拍子 = [" .. timeSigList[idx].numerator .. "/" .. timeSigList[idx].denominator ..
			"]\nです.続けますか?"
		retCode = VSMessageBox(msg, 4)	-- MB_YESNO
		if (retCode == 7) then			-- IDNO
			-- 「いいえ」を選んだので終了します.
			return 0
		end
	end


	-- シーケンス情報を取得します.
	local sequenceName = VSGetSequenceName()
	local sequencePath = VSGetSequencePath()
	local resolution = VSGetResolution()

	-- 取得したシーケンス情報をメッセージボックスへ表示します.
	msg =
		"取得したシーケンス情報は,\n" ..
		"  シーケンス名 = [" .. sequenceName ..
		"]\n  ファイルパス = [" .. sequencePath ..
		"]\n  時間分解能 = [" .. resolution ..
		"]\nです.続けますか?"
	retCode = VSMessageBox(msg, 4)	-- MB_YESNO
	if (retCode == 7) then			-- IDNO
		-- 「いいえ」を選んだので終了します.
		return 0
	end


	-- 正常終了.
	return 0
end
