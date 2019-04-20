--
-- NoteSample2.lua
-- ノートの削除のサンプル.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "ノートの削除のサンプル",
        comment       = "ノートの削除のサンプルJobプラグイン",
        author        = "Yamaha Corporation",
        pluginID      = "{6B749178-0913-47e0-97D5-4BD8DEAE620A}",
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


	local note     = {}
	local noteList = {}
	local noteCount
	local retCode
	local idx

	-- ノートを取得してノートイベント配列へ格納します.
	VSSeekToBeginNote()
	idx = 1
	retCode, note = VSGetNextNote()
	while (retCode == 1) do
		noteList[idx] = note
		retCode, note = VSGetNextNote()
		idx = idx + 1
	end

	-- 読み込んだノートの総数.
	noteCount = table.getn(noteList)
	if (noteCount == 0) then
		VSMessageBox("読み込んだノートがありません.", 0)
		return 0
	end
	
	
	-- 選択範囲のノートイベントを削除します.
	for idx = 1, noteCount do
		local delNote = {}
		delNote = noteList[idx]
		
		if (beginPosTick <= delNote.posTick and delNote.posTick <= endPosTick) then
			retCode = VSRemoveNote(delNote);
			if (retCode ~= 1) then
				VSMessageBox("削除エラー発生!!", 0)
				return 1
			end
		end
	end


	-- 正常終了.
	return 0
end
