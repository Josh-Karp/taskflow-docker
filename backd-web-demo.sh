#!/bin/bash

set -e

CLIENT_ID=""
SECRET=""

for ((i=1;i<=$#;i++)); 
do
    if [ ${!i} = "-client_id" ] 
    then ((i++)) 
        CLIENT_ID=${!i};
    elif [ ${!i} = "-secret" ];
    then ((i++)) 
        SECRET=${!i};
    fi
done;

echo "Plaid CLIENT_ID: $CLIENT_ID"
echo "Plaid SECRET: $SECRET"

docker exec -i odoo12 bash -c "odoo shell -d localhost --db_host db --db_user odoo --db_password odoo" <<EOF

# Create a demo Taskflow instance for the Backd dashboard

# Uninstall IAP module
if env['ir.module.module'].search([('name', '=', 'iap')]).state != 'uninstalled':
    env['ir.module.module'].search([('name', '=', 'iap')]).button_immediate_uninstall()
    print("IAP module uninstalled successfully")


# Disable all crons
crons = env['ir.cron'].search([])
while len(crons) > 0:
    for cron in crons:
        cron.write({'active': False})
        env.cr.commit()
        print("Cron {} disabled successfully".format(cron.id))
    crons = env['ir.cron'].search([])

# Add CRM pipeline & stages
if len(env['crm.team'].search([('name', '=', 'Online Applications')])) == 0:
    team = env['crm.team'].create({'name': 'Online Applications', 'use_opportunities': True})
    env.cr.commit()
    print("Team created successfully: {}".format(team.id))

    stages = ['Business Details', 'Bank Statements', 'Submitted']
    stage_ids = []
    for stage in stages:
        if len(env['crm.stage'].search([('name', '=', stage)])) == 0:
            new_stage = env['crm.stage'].create({'name': stage, 'team_id': team.id})
            stage_ids.append(new_stage.id)
            env.cr.commit()
            print("Stage created successfully: {}".format(stage))

# Remove default CRM stages
default_stages = ['New', 'Qualified', 'Proposition', 'Won']
leads_with_default_stages = env['crm.lead'].search([('stage_id', 'in', default_stages), '|', ("active", "=", False), ("active", "=", True)])
for lead in leads_with_default_stages:
    lead.write({'stage_id': stage_ids[0], 'team_id': team.id})
    env.cr.commit()
    print("Moved lead {} stage id to {}".format(lead.id, stage_ids[0]))

# Remove default CRM pipelines
default_teams = ['America', 'Europe']
for default_team in default_teams:
    team = env['crm.team'].search([('name', '=', default_team)])
    if team:
        team.unlink()
        env.cr.commit()
        print("Default team {} removed successfully".format(default_team))

for default_stage in default_stages:
    stage = env['crm.stage'].search([('name', '=', default_stage)])
    if stage:
        stage.unlink()
        env.cr.commit()
        print("Default stage {} removed successfully".format(default_stage))

# Add demo users
if len((env['res.users'].search([('login', '=', 'joshua@taskflow.co.za')]))) == 0:
    env['res.users'].create({'name': 'Joshua Karp', 'login': 'joshua@taskflow.co.za', 'password': 'demo'})
    env.cr.commit()
    print("Demo user created successfully")

# Add CRM lead products
lead_products = ['Working Capital', 'Line of Credit']
for product in lead_products:
    if env['lead.product'].search([('name', '=', product)]) == False:
        env['lead.product'].create({'name': product})
        env.cr.commit()
        print("Lead product {} created successfully".format(product))

# Add Plaid sandbox credentials
if len(env['plaid.account'].search([('client_id', '=', '$CLIENT_ID')])) == 0:
    env['plaid.account'].create({'client_id': '$CLIENT_ID','secret': '$SECRET', 'account_type': 'sandbox', 'active': True,'assets_webhook': 'https://backd-qa.tasksuite.com/plaid/assets/report'})
    env.cr.commit()
    print("Plaid sandbox credentials created successfully")

print("Demo instance updated successfully")

exit()

EOF
