print_struct_members :: (T: Type, code: string) #expand
{
    #insert -> string 
    {
        t_info := type_info(T);
        builder: String_Builder;  
        defer free_buffers(*builder);
        for fields: t_info.members 
        {
            print_to_builder(*builder, "print(\"%1: \%\\n\", `%2.%1);", fields.name, code);
        }
        result := builder_to_string(*builder);
        return result;
    }
}

display_struct_members :: (T: Type, code: string) #expand
{
    #insert -> string 
    {
        t_info := type_info(T);
        builder: String_Builder;  
        defer free_buffers(*builder);
        for fields: t_info.members 
        {
            print_to_builder(*builder, "ImGui.Text(\"%1: \%\\n\", `%2.%1);", fields.name, code);
        }
        result := builder_to_string(*builder);
        return result;
    }
}

append_with_newline :: (builder: *String_Builder, str: string, args: .. Any)
{
    text := join(str, "\n");
    append(builder, tprint(text, args));
}