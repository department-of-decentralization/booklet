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
    raw(start + " CEST" +  " -- " + proposal["slot"]["room"]["en"].to_s)
    <##\\ ##>
    raw(proposal["track"]["en"].to_s + " -- " + proposal["submission_type"]["en"].to_s)
    <##}\\[1em] ##>

    proposal["abstract"].strip!
    if !proposal["abstract"].empty? and proposal["abstract"][-1] != "." and proposal["abstract"][-1] != "!" and proposal["abstract"][-1] != "?"and proposal["abstract"][-1] != "_"
      proposal["abstract"] += "."
    end

    proposal["description"].strip!
    if !proposal["description"].empty? and proposal["description"][-1] != "." and proposal["description"][-1] != "!" and proposal["description"][-1] != "?"and proposal["abstract"][-1] != "_"
      proposal["description"] += "."
    end

    limit = 1_423
    if proposal["title"].length > 101 || proposal["speakers"].size > 1
      limit = 1_337
    end

    proposal["abstract"].gsub!("blob/main/ONBOARDING.md#onboarding", "")
    proposal["abstract"].gsub!("https://www.allocin.it", "\r\n\r\n https://www.allocin.it")

    raw(parse_md(proposal["abstract"].to_s()))

    clearpage
  end

  cleardoublepage
  <##\include{epilog.tex}##>
end
