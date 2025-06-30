#import "Basic";
#import "GL";
#import "File";
#import "File_Utilities";
#import "AutoLib";
#import "Windows";
#import "System";
#import "Math";
#import "Random";
#load "osu.jai";
#load "app.jai";
#load "util.jai";

main :: ()
{
    app: Application;
    app.name = "ManiaToCatchConverter";
    app.w = 400;
    app.h = 400;

    init_lib(*app, false);

    main_tool_active: bool;

    using mania_catch_converter: Mania_Catch_Converter;
    file_name_buffer = alloc(DEFAULT_PATH_SIZE);
    output_filename_buffer = alloc(DEFAULT_PATH_SIZE);
    output_difficulty_name_buffer = alloc(DEFAULT_PATH_SIZE);
    memset(output_filename_buffer, 0, DEFAULT_PATH_SIZE);
    memset(output_difficulty_name_buffer, 0, DEFAULT_PATH_SIZE);

    while app.running
    {
        reset_temporary_storage();
        handle_events(*app);
        clear_window(*app);

        //Logic
        if app.is_quit
        {
            app.running = false;
        }

        ImGui.Begin("Main", *main_tool_active, 
					IMGUI_WINDOW_FLAGS.NoTitleBar |
					IMGUI_WINDOW_FLAGS.MenuBar | 
					IMGUI_WINDOW_FLAGS.NoMove |
					IMGUI_WINDOW_FLAGS.NoResize |
					IMGUI_WINDOW_FLAGS.NoBackground);

        if ImGui.BeginMenuBar()
        {
            defer ImGui.EndMenuBar();
            if ImGui.BeginMenu("File")
            {
                defer ImGui.EndMenu();
                begin_open_file = ImGui.MenuItem("Open..", "Ctrl+O");
            }
        }
        
        handle_file_action(*mania_catch_converter, app.input);

        if app_state ==
        {
            case .None;
            {
                ImGui.Text("Open osu mania map to begin.");
            }
            case .File_Opened;
            {
                if opened_osu_file.general_info.Mode != 3
                {
                    app_state = .Err_Incorrect_Mode;
                }
                else
                {
                    update_timings(opened_osu_file, *mania_catch_converter);
                    app_state = .Main;
                }
            }
            case .Err_Incorrect_Mode;
            {
                ImGui.Text("Incorrect mode. Please open a mania map.");
            }
            case .Main;
            {
                using mania_catch_converter.opened_osu_file;

                if ImGui.BeginTabBar("MainTabBar", ImGui.TabBarFlags.None)
                {
                    defer ImGui.EndTabBar();
                    if ImGui.BeginTabItem("Main Settings")
                    {
                        defer ImGui.EndTabItem();

                        ImGui.Text("Difficulty Settings");
                        
                        ImGui.PushItemWidth(200);
                        ImGui.SliderFloat("HP", *difficulty_info.HPDrainRate, 1, 10, "%.1f");
                        ImGui.SliderFloat("CS", *difficulty_info.CircleSize, 1, 10, "%.1f");
                        ImGui.SliderFloat("AR", *difficulty_info.ApproachRate, 1, 10, "%.1f");
                        ImGui.SliderFloat("OD", *difficulty_info.OverallDifficulty, 1, 10, "%.1f");
                        ImGui.Checkbox("No bullshit hypers", *no_bullshit_hypers);
                        if no_bullshit_hypers
                        {
                            if ImGui.InputFloat("Bullshit threshold", *bullshit_threshold, 1, 10, "%.1f")
                            {
                                Clamp(*bullshit_threshold, 50, 200.0);
                            }
                            if ImGui.IsItemHovered() 
                            {
                                ImGui.BeginTooltip();
                                ImGui.PushTextWrapPos(400);
                                ImGui.TextUnformatted("Lower value = allow hyper dash on higher snapping (eg. 1/8), Recommend to set it above 100 for best experience.");
                                ImGui.PopTextWrapPos();
                                ImGui.EndTooltip();
                            }
                            if ImGui.InputFloat("Bullshit tolerance", *bullshit_tolerance, 1, 10, "%.1f")
                            {
                                Clamp(*bullshit_tolerance, 50.0, 1000.0);
                            }
                        }
                        ImGui.NewLine();
                        ImGui.Separator();
                        ImGui.Text("File Settings");
                        ImGui.InputText("Difficulty Name", output_difficulty_name_buffer, DEFAULT_PATH_SIZE);
                        ImGui.InputText("Output File Name", output_filename_buffer, DEFAULT_PATH_SIZE);
                        ImGui.PopItemWidth();
                        if ImGui.Button("Convert")
                        {
                            difficulty_name := to_string(output_difficulty_name_buffer);
                            file_name := to_string(output_filename_buffer);

                            if difficulty_name.count == 0 then difficulty_name = "CTB";
                            if file_name.count == 0
                            {
                                file_name = tprint("% - % (%) [%]", metadata.Artist, metadata.Title, metadata.Creator, difficulty_name);
                            }

                            //print("%\n", difficulty_name);
                            //print("%\n", file_name);

                            temp_osu_file := opened_osu_file;
                            temp_osu_file.metadata.Version = difficulty_name;
                            mania_to_catch(*temp_osu_file, mania_catch_converter);

                            write_osu_file(temp_osu_file, file_name);

                            path := get_absolute_path("./");
                            ShellExecuteA(null, "open", temp_c_string(path), null, null, SW_SHOWDEFAULT);
                        }
                    }
                    if ImGui.BeginTabItem("Metadata Info")
                    {
                        defer ImGui.EndTabItem();
                        ImGui.PushTextWrapPos(400);
                        ImGui.Text("Title: %", metadata.Title);
                        ImGui.Text("Artist: %", metadata.Artist);
                        ImGui.Text("Creator: %", metadata.Creator);
                        ImGui.Text("Version: %", metadata.Version);
                        ImGui.Text("Source: %", metadata.Source);
                        ImGui.Text("Tags: %", metadata.Tags);
                        ImGui.Text("BeatmapID: %", metadata.BeatmapID);
                        ImGui.Text("BeatmapSetID: %", metadata.BeatmapSetID);
                        ImGui.PopTextWrapPos();
                    }
                }
            }
        }

        ImGui.End();

        lock_fps(*app.clock, 60);

        draw_frame(*app);

        update_clock(*app.clock);
    }

}

#import "String";