require "json"
require "time"

require "kramdown"

def load_sessions
  data = ENV['PWD'] + "/sessions.json"
  file = File.read data
  json = JSON.parse file
  if json['count'].to_i === json['results'].size
    confirmed = json['results'].select { |r|
      r['state'] == "confirmed"
    }
    sorted = confirmed.sort_by { |j|
      Time.parse(j["slot"]["start"]).to_i
    }
  end
  return sorted
end

def parse_md markdown
  tex = Kramdown::Document.new(markdown).to_latex
end

<##\include{header.tex}##>
document do
  <##\include{title.tex}##>
  day = 11
  proposals = load_sessions
  proposals.each do |proposal|

    proposal_day = Time.parse(proposal["slot"]["start"]).localtime("+02:00").strftime("%d").to_i

    if proposal_day > day
      <##\section {##>
      raw("Day " + (proposal_day - 11).to_s)
      <##} ##>
      raw(Time.parse(proposal["slot"]["start"]).localtime("+02:00").strftime("%e. %B %Y"))
      cleardoublepage
      day = proposal_day
    end

    if proposal["title"].include?("Ceremony")
      <##\subsection {##>
      raw(proposal["title"])
      <##} ##>
    elsif proposal["title"].include?("Mixer")
      next
    elsif proposal["title"].include?("Lunch")
      next
    else
      names = []
      speakers = proposal["speakers"].each { |s|
        names.push s["name"]
      }
      <##\subsection {##>
      <##\textsc{##>
      raw(names.join(", "))
      <##} ##>
      raw(" -- " + proposal["title"])
      <##} ##>
    end

    start = Time.parse(proposal["slot"]["start"]).localtime("+02:00").strftime("%d.%m.%y %H:%M")

    <##\noindent \textit {##>
    raw(start + " CEST")
    <##\\ ##>
    raw(proposal["slot"]["room"]["en"])
    <##\\ ##>
    raw(proposal["track"]["en"])
    <##}\\[1em] ##>

    proposal["abstract"].strip!
    if !proposal["abstract"].empty? and proposal["abstract"][-1] != "." and proposal["abstract"][-1] != "!" and proposal["abstract"][-1] != "?"
      proposal["abstract"] += "."
    end

  #   proposal["description"].gsub!("https://twitter.com/rphmeier/status/1631467728555974658", "")
  #   proposal["description"].gsub!("https://twitter.com/SkipProtocol/status/1642895191857299458", "")
  #   proposal["description"].gsub!("https://twitter.com/project_shutter/status/1628430652990267393", "")
  #   proposal["description"].gsub!("https://twitter.com/barnabemonnot/status/1628836608270016517", "")

    proposal["description"].strip!
    if !proposal["description"].empty? and proposal["description"][-1] != "." and proposal["description"][-1] != "!" and proposal["description"][-1] != "?"
      proposal["description"] += "."
    end

    limit = 1_423
    if proposal["title"].length > 101 || proposal["speakers"].size > 1
      limit = 1_337
    end

    proposal["abstract"].gsub!("blob/main/ONBOARDING.md#onboarding", "")
    proposal["abstract"].gsub!("https://www.allocin.it", "\r\n\r\n https://www.allocin.it")

    raw(parse_md(proposal["abstract"].to_s()))

    # raw(parse_md(proposal["abstract"].to_s()[0,limit].split("<tags").first))
    # if proposal["abstract"].length < limit && proposal["description"].length > 1
    #   <##\par ##>
    #   raw(parse_md(proposal["description"][0,limit-proposal["abstract"].length].split("<tags").first))
    #   if proposal["abstract"].length + proposal["description"].length > limit
    #     raw("(...)")
    #   end
    # else
    #   if proposal["abstract"].length > limit
    #     raw("(...)")
    #   end
    # end

    clearpage
  end

  cleardoublepage
  <##\include{epilog.tex}##>
end
