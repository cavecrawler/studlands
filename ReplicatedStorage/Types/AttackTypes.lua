-- @ScriptType: ModuleScript
export type AttackInfo = {
	Damage: number,
	Lifetime: number,
	CanHit: boolean,
	TargetedPlayers: {Player},
	SuperStun: number?,
	InvertedHitbox: boolean?,
	Update: (self: Attack, dt: number) -> nil,
	OnStart: (self: Attack) -> nil,
	OnHit: (self: Attack, player: Player?, raycastResult: RaycastResult?) -> nil,
	OnExpire: (self: Attack) -> nil
}

export type Attack = AttackInfo & {
	UUID: string,
	CreatedTick: number,
	ManagedVisualBehavior: (self: Attack) -> nil
}
--
export type Slam = Attack & {
	InitialInternalRadius: number,
	InitialTotalRadius: number,
	FinalInternalRadius: number?,
	FinalTotalRadius: number?,
	InitialHeight: number,
	FinalHeight: number?
}

export type Grab = Attack & {
	Attachment: Attachment,
	Radius: number,
	StaggerTime: number,
	EnemyGrabbingAnimationName: string,
	EnemyGrabbedAnimationName: string,
	TargetAnimationName: string?,
	StaggerAnimationName: string,
	OnBlocked: (self: Attack, player: Player) -> nil
}

export type Beam = Attack & {
	Origin: Vector3 | Attachment,
	Direction: Vector3,
	Width: number,
	MaxLength: number,
	TickRate: number,
	Shape: "Rectangle" | "Sphere" | "Cylinder"
}

export type LingeringAura = Attack & {
	CFrame: CFrame,
	Size: Vector3,
	TickRate: number,
	Shape: "Rectangle" | "Sphere" | "Cylinder"
}

export type ExpandingAura = LingeringAura & {
	Windup: number,
	TimeToReachMaxSize: number,
	InitialSize: Vector3,
	FinalSize: Vector3,
	FinalCFrame: CFrame?
}
--
export type BulletInfo = AttackInfo & {
	CFrame: CFrame,
	Shape: "Sphere" | "Rectangle" | "Cylinder",
	Size: Vector3,
	Model: Model
}

export type Bullet = Attack & BulletInfo & {
	DealtDamageRemote: RemoteEvent,
	DealtDamageRemoteConnection: RBXScriptConnection,
	PierceCount: number
} & ClientObjectTypes.ClientObject
--
export type LinearBullet = Bullet & {
	Speed: number,
	Acceleration: number?,
	MinSpeed: number?,
	MaxSpeed: number?
}

export type Vector3Bullet = Bullet & {
	Speed: Vector3,
	Acceleration: Vector3?,
	MinSpeed: Vector3?,
	MaxSpeed: Vector3?
}
return nil
