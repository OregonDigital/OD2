# A simple script to scrape through the Metadata Application Profile
# Leave map.csv in this directory and this script will generate a file with `property` definitions for each worktype

import csv
import pprint

generic, document, image, video, audio = ([] for i in range(5))
with open('map.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        prop = row[1]
        predicate = row[4]
        facetable = ('', ', :facetable')[row[14] == 'yes']
        multiple = str(row[10] == '{0,n}' or row[10] == '{1,n}').lower()
        workType = row[9]
        controlledClass = row[23]
        skippedClasses = ['Hyrax Collection', 'Language', 'License', 'Types', 'RightsStatement']


        if len(prop) == 0 or len(predicate) <= 1:
            continue
        md = "property %s, predicate: %s, multiple: %s"%(prop, predicate, multiple)

        if controlledClass in skippedClasses:
          pass
        elif controlledClass == 'Location':
            md += ", class_name: Hyrax::ControlledVocabularies::%s"%(controlledClass)
        elif not controlledClass == 'N/A':
            md += ", class_name: OregonDigital::ControlledVocabularies::%s"%(controlledClass)
        md += " do |index|"
        md += "\n  index.as :stored_searchable%s"%(facetable)
        md += "\nend"

        if workType == 'Generic':
            generic.append(md)
        elif workType == 'Document':
            document.append(md)
        elif workType == 'Image':
            image.append(md)
        elif workType == 'Video':
            video.append(md)
        elif workType == 'Audio':
            audio.append(md)

with open('generic', 'w') as f:
    for g in generic:
        f.write(g + "\n\n")
with open('document', 'w') as f:
    for d in document:
        f.write(d + "\n\n")
with open('image', 'w') as f:
    for i in image:
        f.write(i + "\n\n")
with open('video', 'w') as f:
    for v in video:
        f.write(v + "\n\n")
with open('audio', 'w') as f:
    for a in audio:
        f.write(a + "\n\n")
