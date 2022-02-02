AuxiliaryServer = {}
AuxiliaryServer.__index = AuxiliaryServer

local function init(vertex, connections, name, NetworkCard)
    local location = NetworkCard.Location
    for i=1, #connections do
        NetworkCard:send("", 15060, "connect", vertex, connections[i])
    end
    NetworkCard:send("", 15060, "assign_location", vertex, location['x'], location['y'], location['z'])
    if name ~= nil then
        NetworkCard:send("", 15060, "assign_name", vertex, name)
    end
end

local function extract_edges(path, vertex)
    local counter = 0
    local index = 0
    local arr = {}
    for k in string.gmatch(path, '([^,]+)') do
        counter = counter + 1

        if tonumber(k) == vertex then
            index = counter
        end
        arr[counter] = k
    end
    if index ~= 0 then
        return arr[index-1], arr[index+1]
    end
end

function AuxiliaryServer:run_with_screen(vertex, connections, vertex_name, screen, gpu)
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    NetworkCard:open(00000)
    event.listen(NetworkCard)
    init(vertex, connections, vertex_name, NetworkCard)

    local w, h = screen:getSize()
    local scale = 1.25

    local panel_scale = 0.7

    gpu:setSize(math.floor(scale * w * 32), math.floor(scale * h * 15))
    w, h = gpu:getSize()
    print(w, h)

    local panel_width = math.floor(w * panel_scale)
    local panel_x_mid = math.floor((panel_width) / 2) + 2

    local up_button = Button("  ↑", panel_x_mid - w / 10, panel_x_mid + w / 10 + 1, 3, 4, { 0, 0.2, 0, 1 }, { 1, 1, 1, 1 })
    local down_button = Button("  ↓", panel_x_mid - w / 10, panel_x_mid + w / 10 + 1, h - 4, h - 3, { 0, 0.2, 0, 1 }, { 1, 1, 1, 1 })

    local current_dest_label = Button("Current Location", panel_width + 2, w - 3, 3, 4, { 0.05, 0.05, 0.5, 1 }, { 1, 1, 1, 1 })
    local current_dest_text = Button(vertex_name, panel_width + 2, w - 3, 4, 5, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })

    local routing_info_label = Button("Route Info", panel_width + 2, w - 3, 6, 7, { 0.05, 0.05, 0.5, 1 }, { 1, 1, 1, 1 })
    local routing_from_label = Button("From", panel_width + 2, w - 3, 7, 8, { 0, 0, 0, 1 }, { 1, 0.6, 0.2, 1 })
    local routing_to_label = Button("To", panel_width + 2, w - 3, 9, 10, { 0, 0, 0, 1 }, { 1, 0.6, 0.2, 1 })

    local routing_from_text = Button(vertex_name, panel_width + 2, w - 3, 8, 9, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })
    local routing_to_text = Button("", panel_width + 2, w - 3, 10, 11, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })

    local route_button = Button("Compute Route", panel_width + 2, w - 3, 12, 15, { 0, 0.25, 0, 1 }, { 1, 1, 1, 1 })

    local page = PageScroller(5, panel_width + 1, 4, h - 4)

    local function refresh()
        gpu:setBackground(0, 0, 0, 1)
        gpu:fill(0, 0, w, h, " ")

        gpu:setBackground(0.1, 0.1, 0.1, 1)
        gpu:fill(2, 1, w - 4, h - 2, " ")

        gpu:setBackground(0, 0, 0, 1)
        gpu:fill(2 + 2, 1 + 1, panel_width - 4, h - 4, " ")

        gpu:setBackground(0, 4, 0, 1)

        up_button:draw(gpu)
        down_button:draw(gpu)
        current_dest_label:draw(gpu)
        current_dest_text:draw(gpu)

        routing_info_label:draw(gpu)
        routing_from_label:draw(gpu)
        routing_to_label:draw(gpu)

        routing_from_text:draw(gpu)
        routing_to_text:draw(gpu)

        route_button:draw(gpu)

        page:draw(gpu)
    end

    local function scroll_up(_, bool)
        if bool then
            page:scroll("vertical", 0, 2)
        end

    end

    local function scroll_down(_, bool)
        if bool then
            page:scroll("vertical", 0, -2)
        end
    end

    local function hover_selection(button, bool)
        if bool then
            button:setForeground({ 0, 1, 0, 1 })
        else
            button:setForeground({ 1, 1, 1, 1 })
        end
    end

    local function hover_route(button, bool)
        if bool then
            button:setBackground({ 0, 0.05, 0, 1})
        else
            button:setBackground({ 0, 0.25, 0, 1})
        end
    end

    local function select(button, bool, within_button)
        if bool then
            button:setBackground({ 0, 0.1, 0, 1 })
            routing_to_text:set_label(button:get_label())
        elseif not bool and within_button then
            button:setBackground({ 0, 0, 0, 1 })
        end
    end

    local function route(_, bool)
        if bool then
            NetworkCard:send("", 15060, "generate_path", vertex, routing_to_text:get_label())
        end
    end

    local button_back = { 0, 0, 0, 1 }
    local button_fore = { 1, 1, 1, 1 }
    local OFFSET = 1

    page:draw(gpu)

    refresh()
    gpu:flush()

    while true do
        local e, _, x, y, mode, data = event.pull()
        if e == "OnMouseDown" then
            print(x, y)
            up_button:execute(x, y, scroll_up)
            down_button:execute(x, y, scroll_down)
            page:execute(x, y, select, true)
            route_button:execute(x, y, route)

        elseif e == "OnMouseMove" then
            page:execute(x, y, hover_selection, false)
            route_button:execute(x, y, hover_route)

        elseif mode == "new_path" then
            local prev, after = extract_edges(data, vertex)
            local switches, switch
            local switched = {}
            print("Receiving path open request")

            for i=1, #connections do
                switches = component.findComponent(tostring(connections[i]))
                print(connections[i], prev, after)
                for j=1, #switches do
                    switch = component.proxy(switches[j])
                    if connections[i] == tonumber(prev) or connections[i] == tonumber(after) then
                        switch.isSwitchOn = true
                        switched[switches[j]] = true

                    elseif switched[switches[j]] == nil then
                        switch.isSwitchOn = false
                    end
                end
            end

        elseif mode == "auxiliary" and vertex_name ~= nil then
            if page:button_count() == 0 then
                page:add_button(data, 5, panel_width - 1, 4, 5, button_back, { 1, 1, 1, 1 })
            else
                page:add_button_sequential(data, 0, OFFSET, button_back, button_fore)
            end
            page:draw(gpu)
            print("Receiving data for new destinations")
        end
        refresh()
        gpu:flush()
    end
end