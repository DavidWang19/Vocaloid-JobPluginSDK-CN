--
-- DoNothing.lua
-- Sample Script.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "Do Nothing",
        comment       = "Sample Plugin",
        author        = "Yamaha Corporation",
        pluginID      = "{EDC4AAE9-91DF-4f33-ADCA-68A6567A1E0B}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }
    
    return myManifest
end


--
-- 何もしないJobプラグインスクリプト.
--

-- Jobプラグインスクリプトのエントリポイント関数.
function main(processParam, envParam)
    -- 実行時に渡されたパラメータの取得.
    beginPosTick = processParam.beginPosTick  -- 選択範囲の始点時刻.
    endPosTick   = processParam.endPosTick    -- 選択範囲の終点時刻.
    songPosTick  = processParam.songPosTick   -- カレントソングポジション時刻.

    -- 実行時に渡された実行環境パラメータを取得する.
    scriptDir  = envParam.scriptDir   -- スクリプトが配置されているディレクトリパス.
    scriptName = envParam.scriptName  -- スクリプトのファイル名.
    tempDir    = envParam.tempDir     -- Jobプラグインが利用可能な一時ディレクトリパス.

    -- Jobプラグインの処理をここ以下で行います.

    -- 正常終了.
    return 0
end
