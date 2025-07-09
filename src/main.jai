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
    app.w = 500;
    app.h = 500;

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
                    //update_timings(opened_osu_file, *mania_catch_converter);
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
                        ImGui.Checkbox("No pixel jumps", *no_pixel_jumps);
                        tool_tip("Remove pixels when enabled, it is recommended to have it enabled for maps to be playable");
                        if no_pixel_jumps
                        {
                            if ImGui.InputFloat("Trigger distance coefficient", *trigger_distance_coefficient, 0.1, 0.1, "%.1f")
                            {
                                Clamp(*trigger_distance_coefficient, 0.1, 0.9);
                            }
                            tool_tip("The trigger distance coefficient determines how much distance to next is required to make it a hyper. For example if it's at 0.5, it will make a hyper jump if the distance to next is greater than half of trigger distance.");
                            if ImGui.InputFloat("Hyper offset", *adjusted_distance_offset, 0.1, 0.1, "%.1f")
                            {
                                Clamp(*adjusted_distance_offset, 0, 100);
                            }
                            tool_tip("Offset of converted hyper jumps. Higher number = higher spacing");
                        }
                        ImGui.Checkbox("No bullshit hypers", *no_bullshit_hypers);
                        tool_tip("Remove hypers based on user's settings");
                        if no_bullshit_hypers
                        {
                            ImGui.Checkbox("Allow hyper if same direction", *allow_bullshit_hyper_if_same_direction);
                            tool_tip("Ignore all the settings below and allow hyper if the current to next fruit's direction is the same as previous");
                            ImGui.Checkbox("No anti-flow", *no_antiflow);
                            tool_tip("Always adjust the spacing to be same as previous direction");
                            if ImGui.InputFloat("Removal ms", *removal_ms, 1, 10, "%.1f")
                            {
                                Clamp(*removal_ms, 50, 200.0);
                            }
                            tool_tip("If the time to next of the current hyper jump is lower than this value then it will remove the current hyper");
                            if ImGui.InputFloat("Spacing tolerance", *bullshit_tolerance, 1, 5, "%.1f")
                            {
                                Clamp(*bullshit_tolerance, 2.0, 20.0);
                            }
                            tool_tip("Lower tolerance = higher spacing between adjusted notes");
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