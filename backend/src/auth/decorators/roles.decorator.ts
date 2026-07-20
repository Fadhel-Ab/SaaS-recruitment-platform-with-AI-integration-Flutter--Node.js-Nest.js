import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../generated/prisma/enums.js';


export const Roles = (...roles: UserRole[]) =>
  SetMetadata('roles', roles);