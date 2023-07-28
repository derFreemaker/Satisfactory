local color = component.findComponent(findClass("Color"))[1]

color.__onDeconstruct:On(function(self)
    print(self.r)
end)

print(color.r)

computer.reset()