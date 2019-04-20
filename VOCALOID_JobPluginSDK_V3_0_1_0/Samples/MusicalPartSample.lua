--
-- Musicalパート情報の取得/更新のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "Musicalパート情報の取得/更新のサンプル",
        comment       = "Musicalパート情報の取得/更新のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{D45979E3-868B-45cc-8E73-8FE92CA59214}",
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


	local musicalPart   = {}
	local musicalSinger = {}
	local retCode
	local msg


	-- Musicalパート情報を取得します.
	retCode, musicalPart = VSGetMusicalPart()

	-- 取得したMusicalパート情報をメッセージボックスへ表示します.
	msg =
		"取得したMusicalパート情報は,\n" ..
		"  posTick = [" .. musicalPart.posTick ..
		"]\n  playTime = [" .. musicalPart.playTime ..
		"]\n  durTick = [" .. musicalPart.durTick ..
		"]\n  name = [" .. musicalPart.name ..
		"]\n  comment = [" .. musicalPart.comment ..
		"]\nです.続けますか?"
	retCode = VSMessageBox(msg, 4)	-- MB_YESNO
	if (retCode == 7) then			-- IDNO
		-- 「いいえ」を選んだので終了します.
		return 0
	end


	-- MusicalパートのバーチャルSinger情報を取得します.
	retCode, musicalSinger = VSGetMusicalPartSinger()

	-- 取得したバーチャルSinger情報をメッセージボックスへ表示します.
	msg =
		"取得したバーチャルSinger情報は,\n" ..
		"  vBS = [" .. musicalSinger.vBS ..
		"]\n  vPC = [" .. musicalSinger.vPC ..
		"]\n  breathiness = [" .. musicalSinger.breathiness ..
		"]\n  brightness = [" .. musicalSinger.brightness ..
		"]\n  clearness = [" .. musicalSinger.clearness ..
		"]\n  genderFactor = [" .. musicalSinger.genderFactor ..
		"]\n  opening = [" .. musicalSinger.opening ..
		"]\n  compID = [" .. musicalSinger.compID ..
		"]\nです.続けますか?"
	retCode = VSMessageBox(msg, 4)	-- MB_YESNO
	if (retCode == 7) then			-- IDNO
		-- 「いいえ」を選んだので終了します.
		return 0
	end


	-- Musicalパート情報を更新します.
	musicalPart.posTick  = musicalPart.posTick + 1920
	musicalPart.playTime = 3840
	musicalPart.name     =
		musicalPart.name ..
		"[" .. musicalSinger.vBS .. "/" .. musicalSinger.vPC ..
		"@" .. musicalSinger.compID ..
		"]"
	musicalPart.comment  = "このMusicalパートは、Jobプラグインから更新されました。@" .. os.date()
	retCode = VSUpdateMusicalPart(musicalPart)


	-- 正常終了.
	return 0
end
