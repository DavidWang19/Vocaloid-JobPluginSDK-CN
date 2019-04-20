--
-- NoteSample1.lua
-- ノートの取得/更新のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "ノートの取得/更新のサンプル",
        comment       = "ノートの取得/更新のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{77E0B197-7E0D-46b5-A78E-FCCE63545372}",
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


	local noteEx     = {}
	local noteExList = {}
	local noteCount
	local retCode
	local idx

	-- ノートを取得してノートイベント配列へ格納します.
	VSSeekToBeginNote()
	idx = 1
	retCode, noteEx = VSGetNextNoteEx()
	while (retCode == 1) do
		noteExList[idx] = noteEx
		retCode, noteEx = VSGetNextNoteEx()
		idx = idx + 1
	end

	-- 読み込んだノートの総数.
	noteCount = table.getn(noteExList)
	if (noteCount == 0) then
		VSMessageBox("読み込んだノートがありません.", 0)
		return 0
	end
	
	
	-- 取得したノートイベントを更新します.
	for idx = 1, noteCount do
		local updNoteEx = {}
		updNoteEx = noteExList[idx]
		
		updNoteEx.lyric    = "ら"
		updNoteEx.phonemes = "4 a"
		
		updNoteEx.bendDepth = 100
		updNoteEx.bendLength = 90
		updNoteEx.risePort = 1
		updNoteEx.fallPort = 1
		updNoteEx.decay = 70
		updNoteEx.accent = 80
		updNoteEx.opening = 20
		updNoteEx.vibratoLength = 100
		updNoteEx.vibratoType = 4
		
		retCode = VSUpdateNoteEx(updNoteEx);
		if (retCode ~= 1) then
			VSMessageBox("更新エラー発生!!", 0)
			return 1
		end
	end


	-- 取得したノートイベントの音程を移調してシーケンスの末尾へ追加します.
	local endPos1 = noteExList[noteCount].posTick + noteExList[noteCount].durTick + 1920
	local endPos2 = endPos1
	for idx = 1, noteCount do
		local newNoteEx = {}
		newNoteEx = noteExList[idx]
		
		endPos2 = endPos1 + newNoteEx.posTick
		
		newNoteEx.posTick = endPos2
		newNoteEx.noteNum = newNoteEx.noteNum + 2
		
		endPos2 = endPos2 + newNoteEx.durTick

		retCode = VSInsertNoteEx(newNoteEx);
		if (retCode ~= 1) then
			VSMessageBox("追加エラー発生!!", 0)
			return 1
		end
	end


	-- MusicalパートのplayTimeを更新します.
	local musicalPart = {}
	retCode, musicalPart = VSGetMusicalPart()
	musicalPart.playTime = endPos2
	retCode = VSUpdateMusicalPart(musicalPart)
	if (retCode ~= 1) then
		VSMessageBox("MusicalパートのplayTimeを更新できません!!", 0)
		return 1
	end


	-- 正常終了.
	return 0
end
