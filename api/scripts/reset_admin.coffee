Referral    = require '../models/referral'
User        = require '../models/user'

{
  adminEmail
  adminPassword
}           = module.context.configuration

{ db }  = require '@arangodb'

do ()->
  referrals = module.context.collection 'referrals'
  {value:referral} = Referral.schema().validate Referral.serializeFromClient
    id: 'admin'
    email: adminEmail
    firstName: 'Admin'
    lastName: 'Adminovich'

    inviterEmailSent:               yes
    subscriptionConfirmed:          yes
    subscriptionConfirmEmailSent:   yes
    affiliateEmailSent:             yes
    didInvitationCreate:            yes
    accepted:                       yes
    registrationEmailSent:          yes

  if referrals.exists 'admin'
    referrals.replace 'admin', referral
  else
    referrals.save referral
  return referral

do ()->
  users = module.context.collection 'users'
  {value:user} = User.schema().validate User.serializeFromClient
    id: 'admin'
    email: adminEmail
    firstName: 'Admin'
    lastName: 'Adminovich'
    inviterId: null
    role: 'admin'
    verified: yes
    verificationEmailSent: yes
  user._owner = 'admin'
  user.authData = FoxxMC::Utils.auth.create adminPassword

  if users.exists 'admin'
    users.replace 'admin', user
  else
    users.save user
  return user


module.exports = yes
