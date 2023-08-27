require "json"
require "time"

def load_sessions
  data = "/home/user/Public/Parity/Protocol-Berg/protocol-booklet/sessions.json"
  file = File.read data
  json = JSON.parse file
  sort = json.sort_by { |j|
    Time.parse(j["Start"]).to_i
  }
end

MAX_PER_PAGE = 1_423
<##\include{header.tex}##>

document do
  <##\include{title.tex}##>

  proposals = load_sessions
  proposals.each do |proposal|

    if proposal["Proposal title"].include?("Opening Ceremony")
      <##\section {##>
      md(proposal["Proposal title"])
      <##} ##>
    elsif proposal["Proposal title"].include?("Post-Conference")
      next
    else
      speakers = proposal["Speaker names"].join(", ")
      <##\section {##>
      <##\textsc{##>
      raw(speakers)
      <##} ##>
      md(" -- " + proposal["Proposal title"])
      <##} ##>
    end

    start = Time.parse(proposal["Start"]).localtime("+02:00").strftime("%H:%M")

    <##\noindent \textit {##>
    md(proposal["Room"]["en"] + ", " + start + " CEST, " + proposal["Track"]["en"])
    <##}\\[1em] ##>

    proposal["Abstract"].strip!
    if !proposal["Abstract"].empty? and proposal["Abstract"][-1] != "." and proposal["Abstract"][-1] != "!" and proposal["Abstract"][-1] != "?"
      proposal["Abstract"] += "."
    end

    proposal["Description"].gsub!("https://twitter.com/rphmeier/status/1631467728555974658", "")
    proposal["Description"].gsub!("https://twitter.com/SkipProtocol/status/1642895191857299458", "")
    proposal["Description"].gsub!("https://twitter.com/project_shutter/status/1628430652990267393", "")
    proposal["Description"].gsub!("https://twitter.com/barnabemonnot/status/1628836608270016517", "")
    proposal["Description"].strip!
    if !proposal["Description"].empty? and proposal["Description"][-1] != "." and proposal["Description"][-1] != "!" and proposal["Description"][-1] != "?"
      proposal["Description"] += "."
    end

    limit = MAX_PER_PAGE
    if proposal["Proposal title"].length > 100
      limit = 1_337
    end

    md(proposal["Abstract"].to_s()[0,limit].split("<tags").first)
    if proposal["Abstract"].length < limit && proposal["Description"].length > 1
      <##\par ##>
      md(proposal["Description"][0,limit-proposal["Abstract"].length].split("<tags").first)
    end

    if proposal["Abstract"].length + proposal["Description"].length > limit
      raw("(...)")
    end

    clearpage
  end

  cleardoublepage
  <##\include{epilog.tex}##>
end
