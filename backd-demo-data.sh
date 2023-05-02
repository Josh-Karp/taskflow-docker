#!/bin/bash

echo "Script started..."

set -x

docker exec -i odoo12 bash -c "odoo shell -d localhost --db_host db --db_user odoo -w odoo" << 'EOF'

# Create Backd dashboard demo data

# Uninstall IAP module
if self.env['ir.module.module'].search([('name', '=', 'iap')]).state != 'uninstalled':
    self.env['ir.module.module'].search([('name', '=', 'iap')]).button_immediate_uninstall()
print("IAP module uninstalled successfully")


# Disable all crons
crons = self.env['ir.cron'].search([])
for cron in crons:
    cron.write({'active': False})
self.env.cr.commit()
print("Crons disabled successfully")

# Add CRM pipeline & stages
if self.env['crm.team'].search([('name', '=', 'Online Applications')]) == False:
    team = self.env['crm.team'].create({'name': 'Online Applications', 'use_opportunities': True})
    print("Team created successfully: {}".format(team.id))

    stages = ['Business Details', 'Bank Statements', 'Submitted']
    stage_ids = []
    for stage in stages:
        if self.env['crm.stage'].search([('name', '=', stage)]) == False:
            new_stage = self.env['crm.stage'].create({'name': stage, 'team_id': team.id})
            stage_ids.append(new_stage.id)
            print("Stage created successfully: {}".format(stage))
    self.env.cr.commit()

# Remove default CRM pipelines
default_teams = ['America', 'Europe']
for default_team in default_teams:
    team = self.env['crm.team'].search([('name', '=', default_team)])
    if team:
        team.unlink()
    self.env.cr.commit()
    print("Default team {} removed successfully".format(default_team))


# Remove default CRM stages
default_stages = ['New', 'Qualified', 'Proposition', Won']
leads_with_default_stages = self.env['crm.lead'].search([('stage_id', 'in', default_stages)])
print("Leads with default stages: {}".format(leads_with_default_stages))
for lead in leads_with_default_stages:
    lead.write({'stage_id': stage_ids[0]})
    self.env.cr.commit()
    print("Removed lead {} stage id".format(lead.id))

for default_stage in default_stages:
    stage = self.env['crm.stage'].search([('name', '=', default_stage)])
    if stage:
        stage.unlink()
    self.env.cr.commit()
    print("Default stage {} removed successfully".format(default_stage))

# Add demo users
if self.env['res.users'].search([('login', '=', 'demo')]) == False:
    self.env['res.users'].create({'name': 'Demo User', 'login': 'demo', 'password': 'demo'})
    self.env.cr.commit()
    print("Demo user created successfully")

# Add CRM lead products
lead_products = ['Working Capital', 'Line of Credit']
for product in lead_products:
    if self.env['lead.product'].search([('name', '=', product)]) == False:
        self.env['lead.product'].create({'name': product})
self.env.cr.commit()
print("Lead products created successfully")

# Add Plaid sandbox credentials
self.env['plaid.account'].create({'client_id': '603e652802cf49000f162916','secret': '60bd32e7dab2747b3072f50029635c', 'account_type': 'sandbox', 'active': True,'assets_webhook': '	https://backd-qa.tasksuite.com/plaid/assets/report'})
print("Plaid sandbox credentials created successfully")

exit