#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'

module Docx2html
  class Parser
    private
    def parse_as_block(r, text)
      if r.parent.previous.nil?
        # first line is package name
        return tag(:h2, text)
      end
      text = text.strip
      # TODO
      # Franzoesisch
      chapters = {
        'Dos./Anw.'       => /^Dosierung\s*\/\s*Anwendung/u, # 5
        'Eigensch.'       => /^Eigenschaften\s*\/\s*Wirkungen($|\s*\(\s*(ATC\-Code|Wirkungsmechanismus|Pharmakodyamik|Klinische\s+Wirksamkeit)\s*\)\s*$)|^Propri.t.s/iu, # 13
        'Galen.Form'      => /^Galenische\s+Form\s+und\s+Wirkstoffmenge\s+pro\s+Einheit$|^Forme\s*gal.nique/iu, # 3
        'Ind./Anw.mögl.'  => /^Indikationen(\s+|\s*\/\s*)Anwendungsm&ouml;glichkeiten$|^Indications/u, # 4
        'Interakt.'       => /^Interaktionen$|^Interactions/u, # 8
        'Kontraind.'      => /^Kontraindikationen($|\s*\(\s*absolute\s+Kontraindikationen\s*\)$)/u, # 6
        'Name'            => /^Name\s+des\s+Pr&auml;parates$/, # 1
        'Packungen'       => /^Packungen($|\s*\(\s*mit\s+Angabe\s+der\s+Abgabekategorie\s*\)$)/u, # 18
        'Präklin.'        => /^Pr&auml;klinische\s+Daten$/u, # 15
        'Pharm.kinetik'   =>  /^Pharmakokinetik($|\s*\((Absorption,\s*Distribution,\s*Metabolisms,\s*Elimination\s|Kinetik\s+spezieller\s+Patientengruppen)*\)$)|^Pharmacocin.tique?/iu, # 14
        'Sonstige H.'     => /^Sonstige\s*Hinweise($|\s*\(\s*(Inkompatibilit&auml;ten|Beeinflussung\s*diagnostischer\s*Methoden|Haltbarkeit|Besondere\s*Lagerungshinweise|Hinweise\s+f&uuml;r\s+die\s+Handhabung)\s*\)$)|^Remarques/u, # 16
        'Schwangerschaft' => /^Schwangerschaft(,\s*|\s*\/\s*)Stillzeit$/u, # 9
        'Stand d. Info.'  => /^Stand\s+der\s+Information$|^Mise\s+.\s+jour$/iu, # 20
        'Unerw.Wirkungen' => /^Unerw&uuml;nschte\s+Wirkungen$/u, # 11
        'Überdos.'        => /^&Uuml;berdosierung$|^Surdosage$/u, # 12
        'Warn.hinw.'      => /^Warnhinweise\s+und\s+Vorsichtsmassnahmen($|\s*\/\s*(relative\s+Kontraindikationen|Warnhinweise\s*und\s*Vorsichtsmassnahmen)$)/u, # 7
        'Fahrtücht.'      => /^Wirkung\s+auf\s+die\s+Fahrt&uuml;chtigkeit\s+und\s+auf\s+das\s+Bedienen\s+von\s+Maschinen$/u, # 10
        'Swissmedic-Nr.'  => /^Zulassungsnummer($|\s*\(\s*Swissmedic\s*\)$)/u, # 17
        'Reg.Inhaber'     => /^Zulassungsinhaberin($|\s*\(\s*Firma\s+und\s+Sitz\s+gem&auml;ss\s*Handelsregisterauszug\s*\))/u, # 19
        'Zusammens.'      => /^Zusammensetzung($|\s*\/\s*(Wirkstoffe|Hilsstoffe)$)/u, # 2
      }.each_pair do |chapter, regexp|
        if text =~ regexp
          next unless r.next.nil? # without line break
          id = CGI.escape(text.gsub(/&(.)uml;/, '\1').gsub(/\s*\/\s*|\/|\s+/, '_').downcase)
          @indecies << {:text => chapter, :id => id}
          return tag(:h3, text, {:id => id})
        end
      end
      nil
    end
  end
  class Builder
    def init
      @container = tag(:div, [], {:id => 'container'})
    end
    private
    def build_after_content
      link = tag(:a, 'Top', {:href => ''})
      tag(:div, link, {:id => 'footer'})
    end
    def build_before_content
      if @indecies
        indices = []
        @indecies.each do |index|
          indices << tag(:li, tag(:a, index[:text], {:href => "#" + index[:id]}))
        end
        tag(:div, tag(:ul, indices), {:id => 'indecies'})
      end
    end
    def style
      style = <<-CSS
table, tr, td {
  border-collapse: collapse;
  border: 1px solid gray;
}
table {
  margin: 5px 0 5px 0;
}
td {
  padding: 5px 10px;
}
body {
  position: relative;
  padding:  0 0 20px 0;
  margin:   0px;
  width:    100%;
  height:   auto;
}
div#indecies {
  position: relative;
  padding:  0px;
  float:    left;
  width:    200px;
}
div#indecies ul {
  margin:  0;
  padding: 0 0 0 25px;
}
div#container {
  position:    relative;
  padding:     0px;
  float:       top left;
  margin-left: 200px;
}
div#footer {
  position:      relative;
  float:         bottom right;
  text-align:    right;
  padding-right: 25px;
}
      CSS
      style.gsub(/\s\s+|\n/, ' ')
    end
  end
end