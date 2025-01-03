// Parameters
param roleAssignments roleAssignmentType[]

module rbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.0' = [for roleAssignment in roleAssignments: {
  name: 'rbac-${take(last(split(roleAssignment.resourceId, '/')), 8)}-${take(roleAssignment.principalId, 8)}-${take(roleAssignment.roleDefinitionId, 8)}'
  params: {
    resourceId: roleAssignment.resourceId
    principalId: roleAssignment.principalId
    roleDefinitionId: roleAssignment.roleDefinitionId
    principalType: roleAssignment.principalType
  }
}]

// Types
type principalType = ('' | 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')

type roleAssignmentType = {
  resourceId: string
  principalId: string
  principalType: principalType  
  roleDefinitionId: string
}
