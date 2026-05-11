local text = "Apply setting (3rd horizontal)"
local ok, lang = pcall(GetCVar, "Language.2")

if ok and type(lang) == "string" and string.sub(string.lower(lang), 1, 2) == "es" then
  text = "Aplicar ajuste (3ª horizontal)"
end

ZO_CreateStringId("SI_BINDING_NAME_EZO_APPLY_PRESETS", text)
