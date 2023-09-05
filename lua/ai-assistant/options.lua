local options = {["openai-host"] = (os.getenv("OPENAI_HOST") or "https://api.openai.com"), ["openai-key"] = (os.getenv("OPENAI_API_KEY") or ""), ["openai-model"] = "gpt-3.5-turbo", provider = "openai", ui = "floating"}
return {options = options}
