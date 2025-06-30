Osu_Hit_Object_Type_Flag :: enum u32
{
    Hit_Circle :: 0x1;
    Slider :: 0x2;
    New_Combo :: 0x4;
    Spinner :: 0x8;
    Mania_Hold :: 0x80;
}

Osu_File_Info :: struct
{
    AudioFilename: string = "";
    AudioLeadIn: int;
    AudioHash: string = "";
    PreviewTime: int; //In ms
    Countdown: int;
    SampleSet: string = "";
    StackLeniency: float;
    Mode: int;
    LetterboxInBreaks: bool;
    StoryFireInFront: bool;
    UseSkinSprites: bool;
    AlwaysShowPlayfield: bool;
    OverlayPosition: string = "";
    SkinPreference: string = "";
    EpilepsyWarning: bool;
    CountdownOffset: int;
    SpecialStyle: bool;
    WidescreenStoryboard: bool;
    SamplesMatchPlaybackRate: bool;
}

Osu_Editor_Info :: struct
{
    Bookmarks: [..] int;
    DistanceSpacing: float;
    BeatDivisor: int;
    GridSize: int;
    TimelineZoom: float;
}

Osu_Metadata :: struct
{
    Title: string = "";
    TitleUnicode: string = "";
    Artist: string = "";
    ArtistUnicode: string = "";
    Creator: string = "";
    Version: string = "";
    Source: string = "";
    Tags: [..] string;
    BeatmapID: int;
    BeatmapSetID: int;
}

Osu_Difficulty_Info :: struct 
{
    HPDrainRate: float;
    CircleSize: float;
    OverallDifficulty: float;
    ApproachRate: float;
    SliderMultiplier: float;
    SliderTickRate: float;
}

Osu_Background_Video_Event :: struct
{
    file_name: string;
    xoffset: int;
    yoffset: int;
}

Osu_Additional_Param :: struct 
{
    end_time: int;
}

Osu_Event :: struct
{
    event_type: string;
    start_time: int;
    background_video_params: Osu_Background_Video_Event;
    other_params: Osu_Additional_Param;
}

Osu_Timing_Point :: struct 
{
    time: int;
    beat_length: float;
    meter: int;
    sample_set: int;
    sample_index: int;
    volume: int;
    uninherited: bool;
    effects: int;
}

Osu_Colour :: struct
{
    combo_colors: [..] Vec3i;
    slider_track_override: Vec3i;
    slider_border: Vec3i;
}

Osu_Slider :: struct
{
    curve_type: string;
    curve_points: [..] string;
    slides: int;
    length: float;
    edge_sounds: [..] int;
    edge_sets: [..] string;
}

Osu_Hit_Sample :: struct
{
    normal_set: int;
    addition_set: int;
    index: int;
    volume: int;
    file_name: string;
}

Osu_Hit_Object :: struct
{
    x: int;
    y: int;
    time: int;
    type: int;
    hitsound: int;
    slider_params: Osu_Slider;
    other_params: Osu_Additional_Param;
    hit_sample: Osu_Hit_Sample;
}

Osu_File :: struct
{
    general_info: Osu_File_Info;
    editor_info: Osu_Editor_Info;
    metadata: Osu_Metadata;
    difficulty_info: Osu_Difficulty_Info;
    events: String_Builder;
    timing_points: [..] Osu_Timing_Point;
    colours: Osu_Colour; 
    hit_objects: [..] Osu_Hit_Object;
}

read_osu_file_info :: (using osu_file_info: *Osu_File_Info, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        //print("%\n", subcategory_entry);
        pair := split(subcategory_entry, ":");
        if pair.count == 2
        {
            key := pair[0];
            value := pair[1];

            //print("%: %\n", key, value);

            if key == 
            {
                case "AudioFilename"; AudioFilename = value;
                case "AudioLeadIn"; AudioLeadIn = string_to_int(value);
                case "AudioHash"; AudioHash = value;
                case "PreviewTime"; PreviewTime = string_to_int(value);
                case "Countdown"; Countdown = string_to_int(value);
                case "SampleSet"; SampleSet = value;
                case "StackLeniency"; StackLeniency = string_to_float(value);
                case "Mode"; Mode = string_to_int(value);
                case "LetterboxInBreaks"; LetterboxInBreaks = xx string_to_int(value);
                case "StoryFireInFront"; StoryFireInFront = xx string_to_int(value);
                case "UseSkinSprites"; UseSkinSprites = xx string_to_int(value);
                case "AlwaysShowPlayfield"; AlwaysShowPlayfield = xx string_to_int(value);
                case "OverlayPosition"; OverlayPosition = value;
                case "SkinPreference"; SkinPreference = value;
                case "EpilepsyWarning"; EpilepsyWarning = xx string_to_int(value);
                case "CountdownOffset"; CountdownOffset = string_to_int(value);
                case "SpecialStyle"; SpecialStyle = xx string_to_int(value);
                case "WidescreenStoryboard"; WidescreenStoryboard = xx string_to_int(value);
                case "SamplesMatchPlaybackRate"; SamplesMatchPlaybackRate = xx string_to_int(value);
            }
        }

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_editor_info :: (using osu_editor_info: *Osu_Editor_Info, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        //print("%\n", subcategory_entry);
        pair := split(subcategory_entry, ":");
        if pair.count == 2
        {
            key := pair[0];
            value := pair[1];

            if key ==
            {
                case "Bookmarks";
                {
                    bookmarks_str := split(value, ",");
                    for bookmarks_str
                    {
                        array_add(*Bookmarks, string_to_int(it));
                    }
                }
                case "DistanceSpacing"; DistanceSpacing = string_to_float(value);
                case "BeatDivisor"; BeatDivisor = string_to_int(value);
                case "GridSize"; GridSize = string_to_int(value);
                case "TimelineZoom"; TimelineZoom = string_to_float(value);
            }
        }

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_metadata :: (using osu_metadata: *Osu_Metadata, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        //print("%\n", subcategory_entry);
        colon_index := find_index_from_left(subcategory_entry, #char ":");
        
        if colon_index > 0
        {
            key := slice(subcategory_entry, 0, colon_index);
            value := slice(subcategory_entry, colon_index+1, subcategory_entry.count-(colon_index+2));

            if key ==
            {
                case "Title"; Title = copy_string(value);
                case "TitleUnicode"; TitleUnicode = copy_string(value);
                case "Artist"; Artist = copy_string(value);
                case "ArtistUnicode"; ArtistUnicode = copy_string(value);
                case "Creator"; Creator = copy_string(value);
                case "Version"; Version = copy_string(value);
                case "Source"; Source = copy_string(value);
                case "Tags";
                {
                    tags_str := split(value, ",");
                    for tags_str
                    {
                        array_add(*Tags, copy_string(it));
                    }
                }
                case "BeatmapID"; BeatmapID = string_to_int(value);
                case "BeatmapSetID"; BeatmapSetID = string_to_int(value);
            }
        }
        
        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_difficulty_info :: (using osu_difficulty_info: *Osu_Difficulty_Info, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        //print("%\n", subcategory_entry);
        pair := split(subcategory_entry, ":");
        if pair.count == 2
        {
            key := pair[0];
            value := pair[1];

            if key ==
            {
                case "HPDrainRate"; HPDrainRate = string_to_float(value);
                case "CircleSize"; CircleSize = string_to_float(value);
                case "OverallDifficulty"; OverallDifficulty = string_to_float(value);
                case "ApproachRate"; ApproachRate = string_to_float(value);
                case "SliderMultiplier"; SliderMultiplier = string_to_float(value);
                case "SliderTickRate"; SliderTickRate = string_to_float(value);
            }
        }

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_events :: (using events: *String_Builder, index: int, entries: [] string) -> int
{
    init_string_builder(events);

    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        print_to_builder(events, "%\n", subcategory_entry);

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_timing_points :: (timing_points: *[..] Osu_Timing_Point, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        timing_points_fields := split(subcategory_entry, ",");
        
        if timing_points_fields.count == 8
        {
            timing_point: Osu_Timing_Point;
            timing_point.time = string_to_int(timing_points_fields[0]);
            timing_point.beat_length = string_to_float(timing_points_fields[1]);
            timing_point.meter = string_to_int(timing_points_fields[2]);
            timing_point.sample_set = string_to_int(timing_points_fields[3]);
            timing_point.sample_index = string_to_int(timing_points_fields[4]);
            timing_point.volume = string_to_int(timing_points_fields[5]);
            timing_point.uninherited = xx string_to_int(timing_points_fields[6]);
            timing_point.effects = string_to_int(timing_points_fields[7]);

            array_add(timing_points, timing_point);
        }

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_colours_info :: (using osu_colour_info: *Osu_Colour, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while !starts_with(subcategory_entry, "[")
    {
        //print("%\n", subcategory_entry);
        pair := split(subcategory_entry, ":");
        if pair.count == 2
        {
            key := pair[0];
            value := pair[1];

            if contains(key, "Combo")
            {
                rgb := split(value, ",");
                color := Vec3i.{string_to_int(rgb[0]), string_to_int(rgb[1]), string_to_int(rgb[2]),};
                array_add(*combo_colors, color);
            }

            if key == 
            {
                case "SliderTrackOverride"; 
                {
                    rgb := split(value, ",");
                    slider_track_override = Vec3i.{string_to_int(rgb[0]), string_to_int(rgb[1]), string_to_int(rgb[2]),};
                }
                case "SliderBorder";
                {
                    rgb := split(value, ",");
                    slider_border = Vec3i.{string_to_int(rgb[0]), string_to_int(rgb[1]), string_to_int(rgb[2]),};
                }
            }
        }

        subcategory_index += 1;
        subcategory_entry = entries[subcategory_index];
    }

    return (subcategory_index - index) - 1; 
}

read_osu_hit_objects :: (hit_objects: *[..] Osu_Hit_Object, index: int, entries: [] string) -> int
{
    subcategory_index := index;
    subcategory_entry := entries[subcategory_index];
    
    while subcategory_index < entries.count
    {
        subcategory_entry = entries[subcategory_index];
        using hit_object: Osu_Hit_Object;
        hit_object_fields := split(subcategory_entry, ",");

        if hit_object_fields.count > 4
        {
            hit_object.x = string_to_int(hit_object_fields[0]);
            hit_object.y = string_to_int(hit_object_fields[1]);
            hit_object.time = string_to_int(hit_object_fields[2]);
            hit_object.type = string_to_int(hit_object_fields[3]);
            hit_object.hitsound = string_to_int(hit_object_fields[4]);

            if hit_object.type & xx Osu_Hit_Object_Type_Flag.Slider
            {
                curve_info := split(hit_object_fields[5], "|");
                slider_params.curve_type = curve_info[0];
                
                for 1 .. curve_info.count-1
                {
                    array_add(*slider_params.curve_points, curve_info[it]);
                }

                slider_params.slides = string_to_int(hit_object_fields[6]);
                slider_params.length = string_to_float(hit_object_fields[7]);   

                if hit_object_fields.count > 9
                {
                    if contains(hit_object_fields[8], #char "|")
                    {
                        edge_sounds_str := split(hit_object_fields[8], "|");
                        for edge_sounds_str
                        {
                            array_add(*slider_params.edge_sounds, string_to_int(it));
                        }
                    }
                }
                
                if hit_object_fields.count > 10
                {
                    if contains(hit_object_fields[9], #char "|") 
                    {
                        edge_sets_str := split(hit_object_fields[9], "|");
                        for edge_sets_str
                        {
                            array_add(*slider_params.edge_sets, it);
                        }
                    }
                }
            } 

            if hit_object.type & xx Osu_Hit_Object_Type_Flag.Spinner
            {
                other_params.end_time = string_to_int(hit_object_fields[5]);
            }

            if hit_object.type & xx Osu_Hit_Object_Type_Flag.Mania_Hold
            {
                hit_sample_str := hit_object_fields[hit_object_fields.count-1];

                hit_sample_fields := split(hit_sample_str, ":");
                other_params.end_time = string_to_int(hit_sample_fields[0]);
                hit_sample.normal_set = string_to_int(hit_sample_fields[1]);
                hit_sample.addition_set = string_to_int(hit_sample_fields[2]);
                hit_sample.index = string_to_int(hit_sample_fields[3]);
                hit_sample.volume = string_to_int(hit_sample_fields[4]);
                hit_sample.file_name = hit_sample_fields[5];
            }
            else
            {
                hit_sample_str := hit_object_fields[hit_object_fields.count-1];
                if contains(hit_sample_str, #char ":")
                {
                    hit_sample_fields := split(hit_sample_str, ":");
                    hit_sample.normal_set = string_to_int(hit_sample_fields[0]);
                    hit_sample.addition_set = string_to_int(hit_sample_fields[1]);
                    hit_sample.index = string_to_int(hit_sample_fields[2]);
                    hit_sample.volume = string_to_int(hit_sample_fields[3]);
                    hit_sample.file_name = hit_sample_fields[4];
                }
            }

            array_add(hit_objects, hit_object);
        }
        
        subcategory_index += 1;
    }

    return (subcategory_index - index) - 1; 
}

read_osu_file :: (path: string) -> Osu_File
{
    file_data, ok := read_entire_file(path);
    osu_file: Osu_File;

    if ok
    {
        entries := split(file_data, "\n");
        
        index := 0;
        while index < entries.count
        {
            current_entry := entries[index];
            if starts_with(current_entry, "[") && 
               contains(current_entry, "General")
            {
                index += 1;
                index += read_osu_file_info(*osu_file.general_info, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "Editor")
            {
                index += 1;
                index += read_osu_editor_info(*osu_file.editor_info, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "Metadata")
            {
                index += 1;
                index += read_osu_metadata(*osu_file.metadata, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "Difficulty")
            {
                index += 1;
                index += read_osu_difficulty_info(*osu_file.difficulty_info, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "Events")
            {
                index += 1;
                index += read_osu_events(*osu_file.events, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "TimingPoints")
            {
                index += 1;
                index += read_osu_timing_points(*osu_file.timing_points, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "Colours")
            {
                index += 1;
                index += read_osu_colours_info(*osu_file.colours, index, entries);
            }

            if starts_with(current_entry, "[") && 
               contains(current_entry, "HitObjects")
            {
                index += 1;
                index += read_osu_hit_objects(*osu_file.hit_objects, index, entries);
            }

            index += 1;
        }
    }

    return osu_file;
}

write_osu_file :: (using osu_file: Osu_File, output_name: string)
{
    //make_directory_if_it_does_not_exist("output");

    file_builder: String_Builder;
    init_string_builder(*file_builder);
    append_with_newline(*file_builder, "osu file format v14");
    append(*file_builder, "\n");

    // General
    append_with_newline(*file_builder, "[General]");
    print_to_builder(*file_builder, "AudioFilename:%\n", general_info.AudioFilename);
    print_to_builder(*file_builder, "AudioLeadIn: %\n", general_info.AudioLeadIn);
    if general_info.AudioHash.count > 0 print_to_builder(*file_builder, "AudioHash: %\n", general_info.AudioHash);
    print_to_builder(*file_builder, "PreviewTime: %\n", general_info.PreviewTime);
    print_to_builder(*file_builder, "Countdown: %\n", general_info.Countdown);
    print_to_builder(*file_builder, "SampleSet:%\n", general_info.SampleSet);
    print_to_builder(*file_builder, "StackLeniency: %\n", general_info.StackLeniency);
    print_to_builder(*file_builder, "Mode: %\n", general_info.Mode);
    print_to_builder(*file_builder, "LetterboxInBreaks: %\n", cast(int)general_info.LetterboxInBreaks);
    if general_info.UseSkinSprites print_to_builder(*file_builder, "UseSkinSprites: %\n", cast(int)general_info.UseSkinSprites);
    if general_info.OverlayPosition.count > 0 print_to_builder(*file_builder, "OverlayPosition: %\n", general_info.OverlayPosition);
    if general_info.SkinPreference.count > 0 print_to_builder(*file_builder, "SkinPreference: %\n", general_info.SkinPreference);
    if general_info.EpilepsyWarning print_to_builder(*file_builder, "EpilepsyWarning: %\n", cast(int)general_info.EpilepsyWarning);
    if general_info.CountdownOffset print_to_builder(*file_builder, "CountdownOffset: %\n", general_info.CountdownOffset);
    if general_info.SpecialStyle print_to_builder(*file_builder, "SpecialStyle: %\n", cast(int)general_info.SpecialStyle);
    if general_info.WidescreenStoryboard print_to_builder(*file_builder, "WidescreenStoryboard: %\n", cast(int)general_info.WidescreenStoryboard);
    if general_info.SamplesMatchPlaybackRate print_to_builder(*file_builder, "SamplesMatchPlaybackRate: %\n", cast(int)general_info.SamplesMatchPlaybackRate);
    append(*file_builder, "\n");
    
    //Editor
    append_with_newline(*file_builder, "[Editor]");
    if editor_info.Bookmarks.count > 0
    {
        append(*file_builder, "Bookmarks: ");
        for editor_info.Bookmarks 
        {
            print_to_builder(*file_builder, "%", it);
            if it_index != editor_info.Bookmarks.count-1
            {
                append(*file_builder, ",");
            }
        }
        append(*file_builder, "\n");
    }
    print_to_builder(*file_builder, "DistanceSpcaing: %\n", editor_info.DistanceSpacing);
    print_to_builder(*file_builder, "BeatDivisor: %\n", editor_info.BeatDivisor);
    print_to_builder(*file_builder, "GridSize: %\n", editor_info.GridSize);
    if editor_info.TimelineZoom != 0 print_to_builder(*file_builder, "TimelineZoom: %\n", editor_info.TimelineZoom);
    append(*file_builder, "\n");

    //Metadata
    append_with_newline(*file_builder, "[Metadata]");
    print_to_builder(*file_builder, "Title:%\n", metadata.Title);
    print_to_builder(*file_builder, "TitleUnicode:%\n", metadata.TitleUnicode);
    print_to_builder(*file_builder, "Artist:%\n", metadata.Artist);
    print_to_builder(*file_builder, "ArtistUnicode:%\n", metadata.ArtistUnicode);
    print_to_builder(*file_builder, "Creator:%\n", metadata.Creator);
    print_to_builder(*file_builder, "Version:%\n", metadata.Version);
    print_to_builder(*file_builder, "Source:%\n", metadata.Source);
    append(*file_builder, "Tags:");
    if metadata.Tags.count > 0
    {
        for metadata.Tags
        {
            print_to_builder(*file_builder, "%", it);
            if it_index != metadata.Tags.count-1
            {
                append(*file_builder, " ");
            }
        }
    }
    append(*file_builder, "\n");
    print_to_builder(*file_builder, "BeatmapID:%\n", metadata.BeatmapID);
    print_to_builder(*file_builder, "BeatmapSetID:%\n", metadata.BeatmapSetID);
    append(*file_builder, "\n");

    //Difficulty
    append_with_newline(*file_builder, "[Difficulty]");
    print_to_builder(*file_builder, "HPDrainRate:%\n", difficulty_info.HPDrainRate);
    print_to_builder(*file_builder, "CircleSize:%\n", difficulty_info.CircleSize);
    print_to_builder(*file_builder, "OverallDifficulty:%\n", difficulty_info.OverallDifficulty);
    print_to_builder(*file_builder, "ApproachRate:%\n", difficulty_info.ApproachRate);
    print_to_builder(*file_builder, "SliderMultiplier:%\n", difficulty_info.SliderMultiplier);
    print_to_builder(*file_builder, "SliderTickRate:%\n", difficulty_info.SliderTickRate);
    append(*file_builder, "\n");

    //Events
    append_with_newline(*file_builder, "[Events]");
    append(*file_builder, builder_to_string(*events));

    //Timing Points
    append_with_newline(*file_builder, "[TimingPoints]");
    for timing_points
    {
        print_to_builder(*file_builder, "%,%,%,%,%,%,%,%\n", it.time, it.beat_length, it.meter, it.sample_set, it.sample_index, it.volume, cast(int)it.uninherited, it.effects);
    }
    append(*file_builder, "\n");

    //Colours
    if colours.combo_colors.count > 0
    {
        append_with_newline(*file_builder, "[Colours]");
        for colours.combo_colors
        {
            print_to_builder(*file_builder, "Combo% : %,%,%\n", it_index+1, it.x, it.y, it.z);
        }
        append(*file_builder, "\n");
    }
    
    //Hit Objects
    append_with_newline(*file_builder, "[HitObjects]");
    for obj : hit_objects
    {
        print_to_builder(*file_builder, "%,%,%,%,%,", obj.x, obj.y, obj.time, obj.type, obj.hitsound);

        if obj.type & xx Osu_Hit_Object_Type_Flag.Slider
        {
            print_to_builder(*file_builder, "%|", obj.slider_params.curve_type);

            for obj.slider_params.curve_points
            {
                print_to_builder(*file_builder, "%", it);
                if it_index != obj.slider_params.curve_points.count-1
                {
                    append(*file_builder, "|");
                }
            }
            append(*file_builder, ",");
            print_to_builder(*file_builder, "%,%", obj.slider_params.slides, obj.slider_params.length);
            append(*file_builder, ",");
            for obj.slider_params.edge_sounds
            {
                print_to_builder(*file_builder, "%", it);
                if it_index != obj.slider_params.edge_sounds.count-1
                {
                    append(*file_builder, "|");
                }
                else
                {
                    append(*file_builder, ",");
                }
            }
            for obj.slider_params.edge_sets
            {
                print_to_builder(*file_builder, "%", it);
                if it_index != obj.slider_params.edge_sets.count-1
                {
                    append(*file_builder, "|");
                }
                else
                {
                    append(*file_builder, ",");
                }
            }
        } 

        if obj.type & xx Osu_Hit_Object_Type_Flag.Spinner
        {
            print_to_builder(*file_builder, "%", obj.other_params.end_time);
            append(*file_builder, ",");
        }

        if obj.type & xx Osu_Hit_Object_Type_Flag.Mania_Hold
        {
            print_to_builder(*file_builder, "%", obj.other_params.end_time);
            append(*file_builder, ":");
        }

        print_to_builder(*file_builder, "%:%:%:%:%\n", obj.hit_sample.normal_set, obj.hit_sample.addition_set, obj.hit_sample.index, obj.hit_sample.volume, obj.hit_sample.file_name);
    }

    output_path := tprint("%.osu", output_name);
    print("output_path: %\n", output_path);
    if !write_entire_file(output_path, *file_builder)
    {
        print("Error: Writing file failed! \n");
    }
}