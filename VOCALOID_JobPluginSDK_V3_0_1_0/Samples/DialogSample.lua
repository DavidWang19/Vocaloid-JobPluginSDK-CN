--
-- DialogSample.lua
-- パラメータ入力ダイアログのサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "パラメータ入力ダイアログサンプル",
        comment       = "パラメータ入力ダイアログのサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{0797F52E-FA39-4359-8BA3-C0F37FC07B1E}",
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


	-- パラメータ入力ダイアログのウィンドウタイトルを設定します.
	VSDlgSetDialogTitle("Jobプラグインパラメータ入力")
	
	-- ダイアログにフィールドを追加します.
	local dlgStatus
	local field = {}
	field.name       = "lyric"
	field.caption    = "歌詞"
	field.initialVal = "さ"
	field.type       = 3
	dlgStatus = VSDlgAddField(field)

	field.name       = "phonemes"
	field.caption    = "発音記号"
	field.initialVal = "s a"
	field.type       = 3
	dlgStatus = VSDlgAddField(field)

	field.name       = "duration"
	field.caption    = "ノート長"
	field.initialVal = "480"
	field.type       = 0
	dlgStatus = VSDlgAddField(field)

	field.name       = "vibratoType"
	field.caption    = "ビブラートタイプ"
	field.initialVal =
		"[Normal] Type 1" ..
		",[Normal] Type 2" ..
		",[Normal] Type 3" ..
		",[Normal] Type 4" ..
		",[Extreme] Type 1" ..
		",[Extreme] Type 2" ..
		",[Extreme] Type 3" ..
		",[Extreme] Type 4" ..
		",[Fast] Type 1" ..
		",[Fast] Type 2" ..
		",[Fast] Type 3" ..
		",[Fast] Type 4" ..
		",[Slight] Type 1" ..
		",[Slight] Type 2" ..
		",[Slight] Type 3" ..
		",[Slight] Type 4"
	field.type = 4
	dlgStatus  = VSDlgAddField(field)

	-- パラメータ入力ダイアログを表示します.
	dlgStatus = VSDlgDoModal()
	if  (dlgStatus ~= 1) then
		-- OKボタンが押されなかったら終了します.
		return 1
	end
	
	-- パラメータ入力ダイアログから入力値を取得します.
	local lyric
	local phonemes
	local duration
	local vibratoType
	dlgStatus, lyric       = VSDlgGetStringValue("lyric")
	dlgStatus, phonemes    = VSDlgGetStringValue("phonemes")
	dlgStatus, duration    = VSDlgGetIntValue("duration")
	dlgStatus, vibratoType = VSDlgGetStringValue("vibratoType")
	
	-- ダイアログからの入力値をメッセージボックスへ表示します.
	local msg
	msg =
		"入力されたパラメータは,\n" ..
		"  lyric = [" .. lyric ..
		"]\n  phonemes = [" .. phonemes ..
		"]\n  duration = [" .. duration ..
		"]\n  vibratoType = [" .. vibratoType ..
		"]\nです."
	VSMessageBox(msg, 0)


	-- 正常終了.
	return 0
end
