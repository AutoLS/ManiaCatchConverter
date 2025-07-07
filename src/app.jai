DEFAULT_PATH_SIZE :: 1024;

App_State :: enum u32
{
    None;
    File_Opened;
    Err_Incorrect_Mode;
    Main;
}

Snapping :: enum u32
{
    White_Tick;
    Red_Tick;
    Purple_Tick;
    Blue_Tick;
    Dark_Purple_Tick;
    Yellow_Tick;
    One_Fifth;
    One_Seventh;
    One_Ninth;
    One_Twelveth;
    One_Sixteenth;
}

Timing_Info :: struct
{
    time: int;
    bpm: float;
    one_measure_ms: [#run enum_highest_value(Snapping)+1] int;
    meter: int;
}

Mania_Catch_Converter :: struct 
{
    app_state: App_State;
    opened_osu_file: Osu_File;

    timings: [..] Timing_Info;
    
    begin_open_file: bool;
    opened_file_name: string;
    file_name_buffer: *u8;

    output_filename_buffer: *u8;
    output_difficulty_name_buffer: *u8;

    trigger_distance_coefficient: float = 0.5;
    adjusted_distance_offset: float = 20;

    no_bullshit_hypers: bool = true;
    allow_bullshit_hyper_if_same_direction: bool = false;
    no_antiflow: bool = true;
    bullshit_tolerance: float = 5.0;
    removal_ms: float = 100.0;
}

get_closest_snapping :: (ms: int, timing_info: Timing_Info) -> Snapping
{
    min := S64_MAX;
    snap: Snapping;
    for timing_info.one_measure_ms
    {
        difference := abs(it - ms);
        if difference < min 
        {
            min = difference;
            snap = xx it_index;
        }
    }

    return snap;
}

update_timings :: (using osu_file: Osu_File, using app: *Mania_Catch_Converter)
{
    array_reset_keeping_memory(*timings);
    for timing_points
    {
        if it.uninherited
        {
            array_add(*timings, calculate_timing_info(it));
        }
    }
}

free_if_there_is_exisiting_memory :: (using osu_file: *Osu_File)
{
    if hit_objects.data && hit_objects.count > 0
    {
        array_free(hit_objects);
    }

    if timing_points.data && timing_points.count > 0
    {
        array_free(timing_points);
    }

    if metadata.Tags.data && metadata.Tags.count > 0
    {
        array_free(metadata.Tags);
    }

    if editor_info.Bookmarks.data && editor_info.Bookmarks.count > 0
    {
        array_free(editor_info.Bookmarks);
    }

    if colours.combo_colors.data && colours.combo_colors.count > 0
    {
        array_free(colours.combo_colors);
    }

    if metadata.Title.data then free(metadata.Title);
    if metadata.TitleUnicode.data then free(metadata.TitleUnicode);
    if metadata.Artist.data then free(metadata.Artist);
    if metadata.ArtistUnicode.data then free(metadata.ArtistUnicode);
    if metadata.Creator.data then free(metadata.Creator);
    if metadata.Version.data then free(metadata.Version);
    if metadata.Source.data then free(metadata.Source);
}

handle_file_action :: (using app: *Mania_Catch_Converter, input: Input)
{
    open_file_shortcut := key_down(input, .lctrl) && key_ended_down(input, .o);

    if begin_open_file || open_file_shortcut
    {
        opened_file_name = open_file_dialogue(file_name_buffer);

        if opened_file_name.count > 0
        {
            free_if_there_is_exisiting_memory(*opened_osu_file);
            opened_osu_file = read_osu_file(opened_file_name);
            app_state = .File_Opened;     
        }

        begin_open_file = false;
    }
}

get_open_file_name :: (filter: *u8, ext: *u8, file_name: *u8, size: s32 = DEFAULT_PATH_SIZE) -> OPENFILENAME(u8)
{
    initial_dir := path_strip_filename(get_path_of_running_executable());
    replace_chars(initial_dir, "/", #char "\\");
    file_dialogue: OPENFILENAME(u8);
    file_dialogue.lStructSize = size_of(OPENFILENAME(u8));
    file_dialogue.lpstrFilter = filter;
    file_dialogue.lpstrDefExt = ext;
    file_dialogue.nMaxFile = xx size;
    file_dialogue.lpstrFile = file_name;
    file_dialogue.lpstrInitialDir = temp_c_string(initial_dir);

    return file_dialogue;
}

open_file_dialogue :: (file_name_buffer: *u8) -> string
{
    file_dialogue := get_open_file_name("Osu files (*.osu)\0*.osu\0\0", "osu", file_name_buffer);

    if GetOpenFileNameA(*file_dialogue)
    {
        return to_string(file_dialogue.lpstrFile);
    }

    return "";
}

calculate_timing_info :: (using timing_point: Osu_Timing_Point) -> Timing_Info
{
    timing_info: Timing_Info;
    timing_info.time = timing_point.time;
    timing_info.bpm = 1 / beat_length * 1000 * 60;
    timing_info.meter = timing_point.meter;

    base_one_measure_ms := cast(int)(60000 / timing_info.bpm);
    timing_info.one_measure_ms[Snapping.White_Tick] = base_one_measure_ms;
    timing_info.one_measure_ms[Snapping.Red_Tick] = base_one_measure_ms / 2;
    timing_info.one_measure_ms[Snapping.Purple_Tick] = base_one_measure_ms / 3;
    timing_info.one_measure_ms[Snapping.Blue_Tick] = base_one_measure_ms / 4;
    timing_info.one_measure_ms[Snapping.Dark_Purple_Tick] = base_one_measure_ms / 6;
    timing_info.one_measure_ms[Snapping.Yellow_Tick] = base_one_measure_ms / 8;
    timing_info.one_measure_ms[Snapping.One_Fifth] = base_one_measure_ms / 5;
    timing_info.one_measure_ms[Snapping.One_Seventh] = base_one_measure_ms / 7;
    timing_info.one_measure_ms[Snapping.One_Ninth] = base_one_measure_ms / 9;
    timing_info.one_measure_ms[Snapping.One_Twelveth] = base_one_measure_ms / 12;
    timing_info.one_measure_ms[Snapping.One_Sixteenth] = base_one_measure_ms / 16;

    return timing_info;
}

mania_to_catch :: (using osu_file: *Osu_File, using app: Mania_Catch_Converter)
{
    osu_file.general_info.Mode = 2;

    new_combo_count := 4;
    previous_time := -1;
    
    converted_hit_objects: [..] Osu_Hit_Object;
    converted_hit_objects.allocator = temp;

    for hit_objects
    {
        new_hit_object: Osu_Hit_Object = it;

        if it.time == previous_time 
        {
            continue;
        }

        if it.type & xx Osu_Hit_Object_Type_Flag.Mania_Hold
        {
            new_hit_object.type = ifx new_combo_count == 4 then 5 else 1;
        }
        else
        {
            new_hit_object.type = ifx new_combo_count == 4 then 5 else 1;
        }

        array_add(*converted_hit_objects, new_hit_object);

        if new_combo_count == 4
        {
            new_combo_count = 0;
        }

        new_combo_count += 1;
        previous_time = it.time;
    }

    //? I have no fucking idea how this calculation works, credits to greaper tools 
    catch_difficulty := (difficulty_info.CircleSize - 5.0) / 5.0;
    fruit_width := (64.0 * (1.0 - 0.699999988079071 * catch_difficulty)) / 128.0;
    catcher_width := 305.0 * fruit_width * 0.7;
    half_fruit_width := fruit_width / 2.0;
    half_catcher_width := catcher_width / 2.0;

    last_direction := 0;
    last_is_hyper: bool = false;

    for converted_hit_objects
    {
        current_object := *it;
        next_object: *Osu_Hit_Object;

        if it_index + 1 < converted_hit_objects.count
        {
            next_object = *converted_hit_objects[it_index+1];
        }
        else
        {
            break;
        }

        current_timing: Timing_Info;
        for timings
        {
            next_timing: Timing_Info;
            if it_index + 1 < timings.count
            {
                next_timing = timings[it_index+1];

                if current_object.time >= it.time && current_object.time < next_timing.time
                {
                    current_timing = it;
                }
                else
                {
                    continue;
                }
            }
            else
            {
                current_timing = it;
            }
        }

        this_direction := ifx next_object.x > current_object.x then 1 else -1;
        time_to_next := next_object.time - current_object.time;
        snapping := get_closest_snapping(xx time_to_next, current_timing);
        trigger_distance := current_timing.one_measure_ms[snapping] - (1000.0 / 60.0 / 4) + half_catcher_width;

        distance_to_next := cast(float)abs(next_object.x - current_object.x);

        if distance_to_next < xx trigger_distance
        {
            //!Naive attempt to fix pixel jumps
            if distance_to_next > trigger_distance * trigger_distance_coefficient
            {
                adjusted_distance := this_direction * (trigger_distance + adjusted_distance_offset);
                next_object.x = current_object.x + xx adjusted_distance;
                Clamp(*next_object.x, 16, 496);
                last_is_hyper = true;
            }
            else
            {
                last_is_hyper = false;
            }
        }
        else 
        {
            last_is_hyper = true;
            skip_hyper := false;

            if allow_bullshit_hyper_if_same_direction
            {
                skip_hyper = this_direction == last_direction;
            }
            
            //Remove bullshit hypers 
            if xx time_to_next < removal_ms && no_bullshit_hypers && !skip_hyper
            {
                adjusted_distance := trigger_distance * (1 / bullshit_tolerance);
                //walk_distance := bullshit_tolerance * (time_to_next/1000.0);
                next_object.x = ifx no_antiflow 
                                then current_object.x + cast(int)(last_direction * adjusted_distance)
                                else current_object.x + cast(int)(this_direction * adjusted_distance);
                Clamp(*next_object.x, 16, 496);
                last_is_hyper = false;
            }
        }

        last_direction = this_direction;
    }

    hit_objects = converted_hit_objects;
}