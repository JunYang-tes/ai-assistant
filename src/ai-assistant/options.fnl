(local options
  {:openai-host (or
                  (os.getenv :OPENAI_HOST)
                  :https://api.openai.com)
   :openai-key (or
                 (os.getenv :OPENAI_API_KEY)
                 "")
   :openai-model "gpt-3.5-turbo"
   :context "openai"
   :ui "floating"})

{: options}
