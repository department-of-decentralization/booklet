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
      if proposal_day == 12
      raw("Day one unfolds with a series of sessions delving into the technical and philosophical underpinnings of decentralized systems. Topics span from the intricacies of distributed virtual machines to the challenges of decentralized infrastructure management. Workshops and talks encourage participants to engage critically with the material, questioning prevailing paradigms and envisioning alternative frameworks for digital interaction. The absence of product pitches and marketing ensures that discussions remain focused on substantive issues, aligning with the event's commitment to authenticity and depth.")
      <##\par ##>
      raw("As the day progresses, attendees are invited to partake in dialogues that challenge conventional thought and inspire revolutionary ideas. The convergence of diverse perspectives fosters a dynamic atmosphere where innovation thrives. Thus, Protocol Berg v2 serves not merely as a conference but as a catalyst for transformative action, galvanizing a community dedicated to reimagining the digital landscape through the lens of decentralization and autonomy.")
      else
      raw("On June 13, 2025, Protocol Berg v2 continues its exploration of decentralized systems at Berlin's Filmtheater Colosseum. This second day delves deeper into the technical and philosophical dimensions of decentralized infrastructure, fostering discussions that challenge conventional paradigms and inspire revolutionary ideas.")
      <##\par ##>
      raw("The day's sessions encompass a range of topics, including advanced consensus mechanisms, innovative networking protocols, and the societal implications of decentralized governance. Workshops and talks encourage participants to critically engage with the material, envisioning alternative frameworks for digital interaction that prioritize autonomy and resilience. The event's commitment to authenticity ensures that discussions remain focused on substantive issues, free from commercial influence.")
      <##\par ##>
      raw("As the conference concludes, attendees are invited to partake in dialogues that transcend traditional boundaries, fostering a dynamic atmosphere where innovation thrives. Thus, Protocol Berg v2 serves not merely as a conference but as a catalyst for transformative action, galvanizing a community dedicated to reimagining the digital landscape through the lens of decentralization and autonomy.")
      <##\par ##>
      end
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
    if !proposal["abstract"].empty? and proposal["abstract"][-1] != "." and proposal["abstract"][-1] != "!" and proposal["abstract"][-1] != "?" and proposal["abstract"][-1] != "_" and proposal["abstract"][-1] != "/" and proposal["abstract"][-3..-1] != "pdf"
      proposal["abstract"] += "."
    end

    proposal["description"].strip!
    if !proposal["description"].empty? and proposal["description"][-1] != "." and proposal["description"][-1] != "!" and proposal["description"][-1] != "?" and proposal["abstract"][-1] != "_" and proposal["abstract"][-1] != "/" and proposal["abstract"][-3..-1] != "pdf"
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
  cleardoublepage
  cleardoublepage
  <##\include{epilog.tex}##>
end
